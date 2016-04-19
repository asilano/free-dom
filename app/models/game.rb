class Game < ActiveRecord::Base
  class_attribute :current
  class_attribute :current_act_parent
  #class_attribute :question_hash

  #self.question_hash = Hash.new { |_| [] }

  extend FauxField

  def self.parent_act
    return nil unless self.current_act_parent
    raise "ID mismatch on parent_act" if self.current_act_parent.game.id != self.current.id
    self.current_act_parent
  end

  def self.parent_act=(act)
    raise "ID mismatch on setting parent_act" if self.current.id != act.game.id
    self.current_act_parent = act
  end

  module TurnPhases
    ACTION = 1
    BUY = 2
    CLEAN_UP = 3

    AllPhases = [ACTION, BUY, CLEAN_UP]
  end

  #has_many :piles, -> { order :position }, :dependent => :destroy
  #accepts_nested_attributes_for :piles
  #has_many :cards, :dependent => :delete_all
  has_many :journals, -> { order :order }
  has_many :players, -> { order :seat, :id }, :dependent => :destroy, inverse_of: :game
  #has_one :current_turn_player, -> { where { cash != nil } }, :class_name => 'Player'
  has_many :users, :through => :players
  #has_many :histories, -> { order :created_at }, :dependent => :delete_all
  has_many :chats, -> { order :created_at }, :dependent => :delete_all
  #serialize :facts

  # Things that used to be database fields and relations
  faux_field [:questions, []], [:state, {}], [:facts, {}], :turn_count, [:piles, []], [:cards, []],
              :current_turn_player, :turn_phase, :last_blocked_journal

  attr_accessor :random_select, :specify_distr, :plat_colony
  attr_accessor *(Card.expansions.map {|set| "num_#{set.name.underscore}_cards".to_sym})
  attr_accessor *(Card.expansions.map {|set| "#{set.name.underscore}_present".to_sym})
  attr_accessor(*(1..10).map{|n| "pile_#{n}".to_sym})

  # A game should only ever have one root pending action outstanding
  # - which will usually be "end the turn".
  #has_one :root_action, -> { where(parent_id: nil) }, :class_name => "PendingAction"
  #has_many :pending_actions, :dependent => :delete_all

  validates :name, :presence => true
  validates :max_players, :presence => true, :numericality => true, :inclusion => { :in => 2..6, :message => 'must be between 2 and 6 inclusive' }
  #validates :turn_phase, :numericality => true, :inclusion => {:in => TurnPhases::AllPhases, :message => 'must be valid'}, :allow_blank => true

  validate :unique_valid_piles, :on => :create
  validate :valid_set_counts, :on => :create
  validate :total_cards_10, :on => :create
  validate :some_sets_present, :on => :create

  before_validation :normalise_inputs, :on => :create
  #before_create :init_facts
  after_create :journal_setup, :age_oldest

  # Add a player to game, raising if there's no space
  def add_player(player)
    if players.length < max_players
      players << player
    else
      raise "Game already full!"
    end
  end

  # Process the journals for a game, determining its complete state ex nihilo
  def process_journals
    # First, seed the RNG with a good, pseudo-random seed. The nanosecond count of the creation
    # timestamp should do
    srand(created_at.nsec)

    self.state = 'waiting'
    self.facts = {}
    self.piles = []
    self.cards = Collections::CardsCollection.new
    self.current_turn_player = nil
    self.last_blocked_journal = 0
    self.questions = []

    # Initial questions: What is the platinum-colony rule, and what piles do we have?
    ask_question(object: self, method: :set_plat_col)
    ask_question(object: self, method: :set_piles)
    if players.count >= 2
      ask_question(object: self, method: :start_game, actor: players.unscoped[0], text: 'Start game')
    end

    # Main loop. For each journal in turn, look for an extant question which wants it as an answer.
    # We shouldn't ever have a journal which doesn't match a question; if we have a question without
    # a journal, then we need to render controls for that question.
    @journal_arr = journals.to_a
    until @journal_arr.empty?

      @current_journal = @journal_arr.shift
      @current_journal.histories = []
      callcc do |cont|
        @cont = cont
        apply_to, index = questions.each_with_index.detect do |q, ix|
          if (q.actor != @current_journal.player)
            false
          else
            q.object.send(q.method, @current_journal, q.actor, check: true)
          end
        end

        if apply_to
          # Found a question that wants it
          questions.delete_at(index) unless index.nil?
          apply_to.object.send(apply_to.method, @current_journal, apply_to.actor)
        elsif hack_game_state(@current_journal, check: true)
          # If nothing else wants it, try the debug hook for adjusting game state
          hack_game_state(@current_journal)
        else
          @current_journal.errors.add(:base, :no_question)
        end

        if @current_journal.errors.any?
          return
        end

        # Check to see if we need to ask for an Action or Buy
        if questions.empty?
          current_turn_player.prompt_for_questions
        end
      end

      # Strategy - apply a Continuation around sending the journal to the receiver.
      #
      # Triggers can then tell Game about any Questions they have; Game must check all its remaining
      # journals for a match (because they may be out of order). If there's a match, carry on; if
      # not, the trigger invokes the continuation. That lets the Game process any other waiting
      # journals while still posting for info on the triggers.
    end

  end

  # Called to stop processing of a journal by invoking the continuation wrapping it.
  def abort_journal
    @cont.call if @cont
  end

  # Called to see if the game-log already has a journal satisfying a question that needs to be
  # asked. If so, removes it from processing and returns it.
  #
  # Expects a template which will be checked against journals to see if they match.
  def find_journal(template)
    desired_journal = @journal_arr.detect { |j| template.match(j.event) }
    if desired_journal
      @journal_arr.delete desired_journal
    end

    desired_journal
  end

  def find_journal_or_ask(template: nil, qn_params: {})
    desired_journal = find_journal(template)
    if desired_journal
      @journal_arr.delete desired_journal
      return desired_journal
    else
      ask_question qn_params
      abort_journal
    end
  end

  # Add a journal to the games journals association - but _not_ to its @journal_arr. This means the
  # caller is free to process the journal immediately.
  def add_journal(journal_params)
    journals.create!(journal_params.merge(order: journals.map(&:order).max + 1))
  end

  # Add a history to the current journal - a record of something that happened as a result of a
  # player choice.
  def add_history(history_params, to_journal = nil)
    to_journal ||= @current_journal
    if to_journal
      to_journal.histories << History.new(history_params)
    end
  end

  def apply_journal_block
    self.last_blocked_journal = @current_journal.order
  end

  def ask_question(q_params)
    q = Question.new(q_params)
    self.questions << q
    q
  end

  def set_plat_col(journal, actor, check: false)
    match = /Setup Platinum\/Colony option: (yes|no|rules)/.match(journal.event)
    ok = actor.nil? && match
    if !ok || check
      return ok
    end

    @plat_colony = match[1]
  end

  def set_piles(journal, actor, check: false)
    match = /Setup piles: ((\w+::\w+,? ?){10})/.match(journal.event)
    ok = actor.nil? && match
    if !ok || check
      return ok
    end

    piles_array = match[1].split(', ')
    piles_array.each do |p|
      begin
        p.constantize
      rescue
        journal.errors.add(:event, ": #{p} is not a card-type.")
        return
      end
    end

    # Prepare to add Platinum and Colony cards if the user (or the rules) say we should
    test_pile = piles_array[rand(10)]
    using_plat_col = false
    if @plat_colony == "yes" ||
        (@plat_colony == "rules" && test_pile.match(/(.*)::/)[1] == "Prosperity")
      using_plat_col = true
    end

    # Create the piles in order, so that the common cards appear first, then the Kingdom
    # Cards sorted by cost. Update their position fields
    posn = 0
    %w<Estate Duchy Province>.each do |vic|
      piles << Pile.new(card_type: "BasicCards::#{vic}", position: posn)
      posn += 1
    end
    if using_plat_col
      piles << Pile.new(card_type: "Prosperity::Colony", position: posn)
      posn += 1
    end
    %w<Copper Silver Gold>.each do |treas|
      piles << Pile.new(card_type: "BasicCards::#{treas}", position: posn)
      posn += 1
    end
    if using_plat_col
      piles << Pile.new(card_type: "Prosperity::Platinum", position: posn)
      posn += 1
    end
    piles << Pile.new(card_type: "BasicCards::Curse", position: posn)
    posn += 1

    sorted_piles = piles_array.sort do |a_str,b_str|
      a = a_str.constantize
      b = b_str.constantize
      (a.cost == b.cost) ? a.name <=> b.name : a.cost <=> b.cost
    end
    sorted_piles.each_with_index do |typ, ix|
      piles << Pile.new(card_type: typ, position: posn + ix)
    end

    piles.each { |p| p.game = self }
  end

  # If the game hasn't started, delete the player object
  def player_stands(player)
    if state != "running"
      histories.create!(:event => "#{player.name} stood up from the game.",
                       :css_class => "meta player#{player.seat} player_leave")
      player.delete
    end
  end

  def start_game(journal, actor, check: false)
    ok = (actor == players.unscoped[0] && journal.event == "#{players.unscoped[0].name} started the game")
    if !ok || check
      return ok
    end

    if state == "running"
      # Game is already running. Odd. Error, and consume the event
      journal.errors.add(:event, ': Game already running')
      return
    elsif players.length < 2 or players.length > max_players
      journal.errors.add(:event, "Invalid number of players (#{players.length})")
      return
    end

    # Setup initial state
    reset_facts
    journal.histories << History.new(:event => "Game started.",
                              :css_class => "meta game_start")
    self.state = "running"
    self.turn_count = 0

    # Populate the piles with the right number of cards.
    piles.each { |pile| pile.populate(players.length) }

    # Initialise tokens for Trade Route mat
    if !cards.of_type("Prosperity::TradeRoute").empty?
      self.facts[:trade_route_value] = 0

      piles.each do |pile|
        if pile.card_class.is_victory?
          pile.state = {} if pile.state.blank?
          pile.state[:trade_route_token] = true
        end
      end
    end

    # Initialise each player's deck and hand
    players.each { |player| player.start_game }

    # Seat the players randomly.
    if players[0].seat.nil?
      seat_order = players.shuffle
      seat_order.each_with_index do |ply, seat|
        ply.seat = seat
        ply.save!
        journal.histories << History.new(:event => "#{ply.name} will play #{(seat + 1).ordinalize}.",
                                          :css_class => "meta player#{seat} start_game")
      end
    else
      seat_order = players
    end

    save!
    seat_order[0].start_turn

    return
  end

  # Process any leaf pending_actions which aren't associated with a player.
  def process_actions
    # First, check if we meet the endgame condition. If we do, we'll need a
    # Game-scope action to perform game-end steps
    check_game_end

    self.pending_actions(true)

    until (acts = pending_actions(true).active.unowned).empty?
      acts.each do |action|
        check_game_end
        case action.expected_action
        when /^resolve_([[:alpha:]]+::[[:alpha:]]+)([0-9]+)(?:_([[:alnum:]_]*))?(;.*)?/
          card_type = $1
          card_id = $2
          substep = $3
          param_string = $4 || ""

          card = card_type.constantize.find(card_id)
          params = {}
          param_string.scan(/;([^;=]*)=([^;=]*)/) {|m| params[m[0].to_sym] = m[1]}
          params[:parent_act] = action.parent
          params[:this_act_id] = action.id
          params[:state] = action.state
          Game.current_act_parent = action.parent
          action.destroy

          if not card.respond_to? substep.to_sym
            return "Unexpected substep #{substep} for #{card_type}"
          end

          card.method(substep.to_sym).call(params)
        when /^player_([[:alpha:]_]+);player=([0-9]+)(;.*)?$/
          player = Player.find($2)
          task = $1
          param_string = $3 || ""
          Game.current_act_parent = action.parent
          params = {:parent_act => action.parent, :this_act_id => action.id}
          param_string.scan(/;([^;=]*)=([^;=]*)/) {|m| params[m[0].to_sym] = m[1]}
          action.destroy

          player.method(task.to_sym).call(params)
        when /^end_game$/
          action.destroy
          end_game
        end
      end
    end

    # Force each player's cards to be renumbered
    players.each do |ply|
      [:deck, :hand, :discard].each {|loc| ply.renum(loc)}
    end
  end

  def check_game_end
    # Determine if the game should end. This is if either
    # - the Province pile is empty
    # - three other piles are empty
    self.reload
    due_to_end = false
    if self.state == "running"
      count = 0
      piles.each do |pile|
        if pile.cards.empty?
          count += 1
          due_to_end = ((count == 3 && players.length <= 4) ||
                        count == 4 ||
                        pile.card_class == BasicCards::Province ||
                        pile.card_class == Prosperity::Colony)
          break if due_to_end
        end
      end
      if due_to_end
        if root_action.nil?
          create_root_action(:expected_action => "end_game")
          histories.create!(:event => "Game will end at end of the current turn.",
                           :css_class => "meta game_end")
        elsif root_action.expected_action != "end_game"
          act = root_action.insert_parent!(:expected_action => "end_game")
          act.game = self
          act.save!
          histories.create!(:event => "Game will end at end of the current turn.",
                           :css_class => "meta game_end")
        end
      end
    end
    return due_to_end
  end

  # Handle the end of the game. This consists of scoring each player, and
  # marking the game as ended
  def end_game
    pending_actions.destroy_all
    players.each {|p| p.calc_score}
    self.state = 'ended'
    self.end_time = Time.now
    save!
    winner = players.sort_by {|p| p.score}[-1]
    histories.create!(:event => "Game ended. #{winner.name} is the winner, with #{winner.score} points!",
                     :css_class => "meta player#{winner.seat} game_end")

    # Call the Ranking model to handle updating the players' rankings
    Ranking.update_rankings(players)

    players.each do |ply|
      # Write the game into the Old Games record, for stats
      OldScore.create!(:game_id => id,
                       :user_id => ply.user.id,
                       :score => ply.score,
                       :result_elo => ply.user.ranking.result_elo,
                       :score_elo => ply.user.ranking.score_elo)

      # Update the last-ended timestamp of the players
      ply.user.last_completed = end_time
      ply.user.save!
    end

    players.each do |ply|
      if ply.user.pbem?
        Player.to_email ||= {}
        Player.to_email[ply.id] ||= {}
        Player.to_email[ply.id][:game_state] = [nil,
                                                "free-dom: Game '#{name}' over",
                                                "Game '#{name}' has ended.",
                                                nil]
      end
    end

    return "OK"
  end

  def last_modified
    [(self.journals.last.andand.created_at || Time.at(0)), (chats.last.andand.created_at || Time.at(0))].max
  end

  def reset_facts
    # Reset Game facts which count things per turn. No point storing more
    # info than needed, though.
    self.facts ||= {}
    if self.facts.include? :bridges
      self.facts[:bridges] = 0
    end
    if self.facts.include?(:actions_played) || !cards.of_type("Intrigue::Conspirator").empty?
      self.facts[:actions_played] = 0
    end
    if self.facts.include? :coppersmiths
      self.facts[:coppersmiths] = 0
    end
    if self.facts.include? :contraband
      self.facts[:contraband] = []
    end
  end

  def waiting_for?(action)
    pending_actions.active.owned.pluck(:expected_action).any? { |exp| exp =~ Regexp.new("^" + action + "(;.*)?") }
  end

  def card_types
    cards.pluck(:type).uniq
  end

  def pile_types
    piles.map(&:card_type)
  end

  def supply_cards
    piles.map { |p| p.cards[0] }
  end

  def expand_random_choices
    if random_select.to_i == 1
      if specify_distr.to_i == 1
        # User chose to have a random selection of Kingdom cards, and will have
        # specified a distribution.
        shuffled_cards = Hash[Card.expansions.map { |set| [set, set.kingdom_cards.shuffle] }]

        pile_id = 0
        Card.expansions.each do |set|
          (0...send("num_#{set.name.underscore}_cards").to_i).each do |ix|
            pile_id += 1
            send("pile_#{pile_id}=", shuffled_cards[set][ix].name)
          end
        end
      else
        # User chose a totally random distibution over specified sets.
        valid_cards = []

        Card.expansions.each do |set|
          valid_cards += set.kingdom_cards if send("#{set.name.underscore}_present").to_i == 1
        end

        valid_cards.shuffle!
        (1..10).each {|ix| send("pile_#{ix}=", valid_cards[ix-1].name) }
      end
    end
  end

  def piles_array
    (1..10).map {|ix| self.send("pile_#{ix}")}
  end

protected
  def unique_valid_piles
    if random_select.to_i != 1
      piles_array.each_with_index do |pile, ix|
        if piles_array.select {|p| p == pile}.length > 1
          errors.add("pile_#{ix+1}", 'must be unique.')
        end
        if !Card.all_kingdom_cards.map(&:name).include? pile
          errors.add("pile_#{ix+1}", 'must be a Kingdom Card.')
        end
      end
    end
  end

  def valid_set_counts
    if random_select.to_i == 1 && specify_distr.to_i == 1
      Card.expansions.each do |exp|
        num = send("num_#{exp.name.underscore}_cards").to_i
        if num < 0 || num > 10 || num > exp.kingdom_cards.count
          errors[:base] << "Number of cards from #{exp.name} must be between 0 and #{[10, exp.kingdom_cards.count].min}"
        end
      end
    end
  end

  def total_cards_10
    if random_select.to_i == 1 && specify_distr.to_i == 1
      sum = Card.expansions.inject(0) {|total, exp| total + self.send("num_#{exp.name.underscore}_cards").to_i}
      if sum != 10
        errors[:base] << "Number of cards from each set must sum to 10."
      end
    end
  end

  def some_sets_present
    if random_select.to_i == 1 && specify_distr.to_i == 0
      if Card.expansions.all? {|set| self.send("#{set.name.underscore}_present") == 0}
        errors[:base] << "Must select at least one set."
      end
    end
  end

  def normalise_inputs
    self.random_select = self.random_select.to_i
    self.specify_distr = self.specify_distr.to_i
    Card.expansions.each do |set|
      meth = "num_#{set.name.underscore}_cards"
      self.send(meth + '=', self.send(meth).to_i)

      meth = "#{set.name.underscore}_present"
      self.send(meth + '=', self.send(meth).to_i)
    end
  end

  def journal_setup
    journals.create!(event: "Setup Platinum/Colony option: #{plat_colony}")

    sorted_piles = piles_array.sort_by do |str|
      type = str.constantize
      [type.cost, type.name]
    end
    journals.create!(event: "Setup piles: #{sorted_piles.join(', ')}")
  end

  def log_creation
    histories.create!(:event => "Game #{name} created.",
                     :css_class => "meta game_create")

    chats.create!(:non_ply_name => "Game", :turn => 0, :statement => "Welcome to '#{name}'!")
  end

  def age_oldest
    while Game.count > 5
      oldest_finished = Game.where { (state == 'ended') & ((end_time == nil) | (end_time < Time.now - 3.days)) }.
                              order(:end_time, :id).first
      if oldest_finished
        oldest_finished.destroy
      else
        break
      end
    end
  end

private
  def hack_game_state(journal, check: false)
    if check || journal.event !~ /^Hack: /
      return journal.event =~ /^Hack: /
    end

    case journal.event
    when /^Hack: (.*) (hand) \+ ([a-zA-Z]*::[a-zA-Z]*)/
      player = players.joins { user }.where { user.name == $1 }.first
      location = $2
      card_class = nil
      begin
        card_class = $3.constantize
      rescue
        journal.errors.add(:event, "Hack mentions bad card type")
      end

      player.cards << card_class.new(game: self,
                                      player: player,
                                      location: location,
                                      position: player.cards.hand.length)

    else
      journal.errors.add(:event, "Hack of unknown type")
    end
  end

end
