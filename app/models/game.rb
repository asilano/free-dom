class Game < ActiveRecord::Base
  class_attribute :current

  extend FauxField

  module TurnPhases
    ACTION = 1
    BUY = 2
    CLEAN_UP = 3

    AllPhases = [ACTION, BUY, CLEAN_UP]
  end

  has_many :journals, -> { order :order }
  has_many :players, -> { order :seat, :id }, :dependent => :destroy, inverse_of: :game
  has_many :users, :through => :players
  has_many :chats, -> { order :created_at }, :dependent => :delete_all

  # Things that used to be database fields and relations
  faux_field :main_strand, [:strands, []], :current_strand, [:state, {}], [:facts, {}], :turn_count, [:piles, []], [:cards, Collections::CardsCollection.new],
              :current_turn_player, :turn_phase, :treasure_step, :last_blocked_journal, [:triggers, {}]

  attr_accessor :random_select, :specify_distr, :plat_colony
  attr_accessor *(Card.expansions.map {|set| "num_#{set.name.underscore}_cards".to_sym})
  attr_accessor *(Card.expansions.map {|set| "#{set.name.underscore}_present".to_sym})
  attr_accessor(*(1..10).map{|n| "pile_#{n}".to_sym})
  attr_reader :current_journal

  validates :name, :presence => true
  validates :max_players, :presence => true, :numericality => true, :inclusion => { :in => 2..6, :message => 'must be between 2 and 6 inclusive' }

  validate :unique_valid_piles, :on => :create
  validate :valid_set_counts, :on => :create
  validate :total_cards_10, :on => :create
  validate :some_sets_present, :on => :create

  before_validation :normalise_inputs, :on => :create
  after_create :journal_setup, :age_oldest, :welcome_chat

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

    init_game

    # Initial questions: What is the platinum-colony rule, and what piles do we have?
    main_strand.ask_question(object: self, method: :set_plat_col)
    main_strand.ask_question(object: self, method: :set_piles)
    if players.count >= 2
      main_strand.ask_question(object: self, method: :start_game, actor: players.unscoped[0], text: 'Start game')
    end

    # Main loop. For each journal in turn, look for an extant question which wants it as an answer.
    # We shouldn't ever have a journal which doesn't match a question; if we have a question without
    # a journal, then we need to render controls for that question.
    @journal_arr = journals.to_a
    until @journal_arr.empty?

      @current_journal = @journal_arr.shift
      @current_journal.histories = []

      Rails.logger.info("Processing journal: #{@current_journal.inspect}")
      Rails.logger.info("Remaining journals: #{@journal_arr.map(&:event)}")
      #Rails.logger.info("Questions: #{questions.map(&:insp)}")
      #Rails.logger.info(main_strand.log)
      callcc do |cont|
        @cont = cont
        matching_strand = strands.detect { |strand| strand.expects_journal(@current_journal) }

        if matching_strand
          # Found a strand that wants it
          current_strand = matching_strand
          matching_strand.apply_journal(@current_journal)
        elsif hack_game_state(@current_journal, check: true)
          # If nothing else wants it, try the debug hook for adjusting game state
          hack_game_state(@current_journal)
        elsif !@current_journal.allow_defer ||
              strands.all? { |strand| strand.questions.empty? }
          @current_journal.errors.add(:base, :no_question)
          Rails.logger.info("No question!")
        elsif !@journal_arr.all?(&:deferred) || !@current_journal.deferred
          @current_journal.deferred = true
          @journal_arr << @current_journal
          next
        else
          return
        end

        if @current_journal.errors.any?
          return
        end

        @journal_arr.each { |j| j.deferred = false }

        # Check to see if we need to ask for an Action or Buy
        if strands.all? { |strand| strand.questions.empty? } && current_turn_player
          current_strand = main_strand
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
  # asked. If so, returns it.
  #
  # Expects a template which will be checked against journals to see if they match.
  def find_journal(template)
    @journal_arr.detect { |j| template.match(j.event) }
  end

  def find_journal_or_ask(template: nil, qn_params: {})
    desired_journal = find_journal(template)
    if desired_journal
      @journal_arr.delete desired_journal
      return desired_journal
    else
      ask_question qn_params
      return nil
    end
  end

  # Add a journal to the game's journals association, and to its @journal_arr. This means the
  # game will process the journal in the normal course of things.
  def add_journal(journal_params)
    journal = journals.create!(journal_params.merge(order: journals.map(&:order).max + 1))
    @journal_arr.andand << journal
    journal
  end

  # Add a history to the current journal - a record of something that happened as a result of a
  # player choice.
  def add_history(history_params, to_journal = nil)
    to_journal ||= @current_journal
    if to_journal
      to_journal.histories << History.new(history_params)
    end
  end

  # Set that this journal, and all journals before it, are not free for edit (because hidden
  # information was revealed).
  def apply_journal_block
    self.last_blocked_journal = @current_journal.order
  end

  def ask_question(q_params)
    (current_strand || main_strand).ask_question(q_params)
  end

  def all_questions
    strands.map(&:questions).flatten
  end

  def questions
    strands.select { |st| st.unblocked? }.map(&:questions).flatten
  end

  def add_strand(parent)
    strand = Strand.new(parent)
    strands << strand
    strand
  end

  # Read the "Use Platinum & Colony" setting from its journal
  def set_plat_col(journal, actor, check: false)
    match = /Setup Platinum\/Colony option: (yes|no|rules)/.match(journal.event)
    ok = actor.nil? && match
    if !ok || check
      return ok
    end

    @plat_colony = match[1]
  end

  # Read the piles to use from its journal
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

  def check_game_end
    # Determine if the game should end. This is if either
    # - the Province or Colony pile is empty
    # - three other piles are empty
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
    players.each {|p| p.calc_score}
    self.state = 'ended'

    first_end = self.end_time.present?
    winner = players.sort_by {|p| p.score}[-1]
    add_history(:event => "Game ended. #{winner.name} is the winner, with #{winner.score} points!",
                     :css_class => "meta player#{winner.seat} game_end")

    if first_end
      self.end_time = Time.now
      save!
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
    end
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

  def card_types
    cards.pluck(:type).uniq
  end

  def pile_types
    piles.map(&:card_type)
  end

  def supply_cards
    piles.map { |p| p.cards[0] || Card.new }
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

  def welcome_chat
    chats.create!(:non_ply_name => "Game", :turn => 0, :statement => "Welcome to '#{name}'!")
  end

  def age_oldest
    while Game.count > 5
      oldest_finished = Game.where { end_time < Time.now - 3.days }.
                              order(:end_time, :id).first
      if oldest_finished
        oldest_finished.destroy
      else
        break
      end
    end
  end

private
  def init_game
    self.state = 'waiting'
    self.facts = {}
    self.piles = []
    self.cards = Collections::CardsCollection.new
    self.current_turn_player = nil
    self.last_blocked_journal = 0
    self.main_strand = Strand.new
    self.current_strand = main_strand
    self.strands = [main_strand]
    self.triggers = {attack: Triggers::OnAttack.new(self)}
  end

  def hack_game_state(journal, check: false)
    if check || journal.event !~ /^Hack: /
      return journal.event =~ /^Hack: /
    end

    case journal.event
    when /^Hack: (.*) (hand|deck|play|discard|enduring) (\+|=) *((?:[a-zA-Z]*::[a-zA-Z]*(?:,\ )?)*)$/
      player = players.joins { user }.where { user.name == $1 }.first
      location = $2

      if $3 == '='
        # Setting location completely. So throw away existing cards
        cards.delete_if { |card| card.player == player && card.location == location }
      end

      card_list = $4.split(/,\s*/)
      card_list.each do |card|
        card_class = nil
        begin
          card_class = card.constantize
        rescue
          journal.errors.add(:event, "Hack mentions bad card type #{card}")
        end

        self.cards << card_class.new(game: self,
                                      player: player,
                                      location: location,
                                      position: player.cards.in_location(location).length)
      end
    when /^Hack: ([a-zA-Z]*::[a-zA-Z]*) in (.*) remove (\d*|all)$/
      card_type = $1
      location = $2
      quantity = $3
      if quantity == 'all'
        cards.delete_if { |card| card.class.to_s == card_type && card.location == location }
      else
        $3.to_i.times do |_|
          ix = cards.index { |card| card.class.to_s == card_type && card.location == location }
          break unless ix
          cards.delete_at(ix)
        end
      end
    when /^Hack: (.*) start turn$/
      player = players.joins { user }.where { user.name == $1 }.first
      self.main_strand = Strand.new
      self.current_strand = main_strand
      self.strands = [main_strand]

      player.start_turn
    else
      journal.errors.add(:event, "Hack of unknown type")
    end
  end

end
