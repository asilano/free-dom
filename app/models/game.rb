class Game < ActiveRecord::Base
  class_attribute :current
  class_attribute :current_act_parent

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

  has_many :piles, :order => "position", :dependent => :destroy
  #accepts_nested_attributes_for :piles
  has_many :cards, :dependent => :delete_all

  has_many :players, :order => "seat, id", :dependent => :destroy
  has_one :current_turn_player, :class_name => 'Player',
                                :conditions => 'cash is not null'
  has_many :users, :through => :players
  has_many :histories, :dependent => :delete_all, :order => "created_at"
  has_many :chats, :dependent => :delete_all, :order => "created_at"
  serialize :facts

  attr_accessor :random_select, :specify_distr, :plat_colony
  attr_accessor *([:base_game, :intrigue, :seaside, :prosperity, :hinterlands].map {|set| "num_#{set}_cards".to_sym})
  attr_accessor *([:base_game, :intrigue, :seaside, :prosperity, :hinterlands].map {|set| "#{set}_present".to_sym})
  attr_accessor(*(1..10).map{|n| "pile_#{n}".to_sym})

  # A game should only ever have one root pending action outstanding
  # - which will usually be "end the turn".
  has_one :root_action, :class_name => "PendingAction",
                        :conditions => "parent_id is null"
  has_many :pending_actions, :dependent => :delete_all
  has_many :active_actions, :class_name => "PendingAction",
                            :finder_sql => proc {"select p.* from pending_actions p where game_id = #{id} and player_id is null and (select count(*) from pending_actions where parent_id = p.id) = 0"},
                            :counter_sql => proc {"select count(*) from pending_actions p where game_id = #{id} and player_id is null and (select count(*) from pending_actions where parent_id = p.id) = 0"}
  has_many :active_ply_actions, :class_name => "PendingAction",
                            :finder_sql => proc {"select p.* from pending_actions p
                                                    where game_id = #{id} and
                                                          player_id is not null and
                                                          text is not null and
                                                          text != '' and
                                                          (select count(*) from pending_actions where parent_id = p.id) = 0"}

  validates :name, :presence => true
  validates :max_players, :presence => true, :numericality => true, :inclusion => { :in => 2..6, :message => 'must be between 2 and 6 inclusive' }
  validates :turn_phase, :numericality => true, :inclusion => {:in => TurnPhases::AllPhases, :message => 'must be valid'}, :allow_blank => true

  validate :unique_valid_piles, :on => :create
  validate :total_cards_10, :on => :create
  validate :some_sets_present, :on => :create

  before_validation :normalise_inputs, :on => :create
  before_create :init_facts
  after_create :expand_random_choices, :make_piles, :log_creation, :age_oldest

  # Add a player to game, raising if there's no space
  def add_player(player)
    if players.length < max_players
      #player.seat = players.length
      players << player
      histories.create!(:event => "#{player.name} joined the game.",
                       :css_class => "meta new_player")

      "OK"
    else
      raise "Game already full!"
    end
  end

  # If the game hasn't started, delete the player object
  def player_stands(player)
    if state != "running"
      histories.create!(:event => "#{player.name} stood up from the game.",
                       :css_class => "meta player#{player.seat} player_leave")
      player.delete
    end
  end

  def start_game
    if state == "running"
      # Game is already running. Odd, but maybe we got a double submission
      # somehow. Log and exit.
      return "OK"
    elsif players.length < 2 or players.length > max_players
      return "Invalid number of players (#{players.length})"
    else
      # To prevent anyone starting the game while we're working, update
      # the state and save now.
      reset_facts
      histories.create!(:event => "Game started.",
                       :css_class => "meta game_start")
      self.state = "running"
      self.turn_count = 0
      save!
    end

    # Populate the piles with the right number of cards.
    piles.each { |pile| pile.populate(players.length) }

    # Initialise tokens for Trade Route mat
    if !cards(true).of_type("Prosperity::TradeRoute").empty?
      self.facts_will_change!
      self.facts[:trade_route_value] = 0

      piles.each do |pile|
        if pile.card_class.is_victory?
          pile.state_will_change!
          pile.state = {} if pile.state.blank?
          pile.state[:trade_route_token] = true
          pile.save!
        end
      end
    end

    # Initialise each player's deck and hand
    players.each { |player| player.start_game }

    # Seat the players randomly and set up the initial tree of Pending Actions
    seat_order = players.shuffle
    seat_order.each_with_index do |ply, seat|
      ply.seat = seat
      ply.save!
      histories.create!(:event => "#{ply.name} will play #{(seat + 1).ordinalize}.",
                       :css_class => "meta player#{seat} start_game")
    end

    seat_order[0].start_turn

    save!
    return "OK"
  end

  # Process any leaf pending_actions which aren't associated with a player.
  def process_actions
    # First, check if we meet the endgame condition. If we do, we'll need a
    # Game-scope action to perform game-end steps
    check_game_end

    self.pending_actions(true)

    until active_actions(true).empty?
      active_actions(true).each do |action|
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
    [self.histories.last.created_at, chats.last.created_at].max
  end

  def reset_facts
    # Reset Game facts which count things per turn. No point storing more
    # info than needed, though.
    facts_will_change!
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

    save!
  end

  def waiting_for?(action)
    active_actions.map {|act| act.expected_action}.any? {|exp| exp =~ Regexp.new("^" + action + "(;.*)?")}
  end

  def card_types
    cards.find(:all, :select => 'type', :group => "cards.type").map {|c| c[:type]}
  end

  def pile_types
    piles.map(&:card_type)
  end

  def expand_random_choices
    if random_select.to_i == 1
      if specify_distr.to_i == 1
        # User chose to have a random selection of Kingdom cards, and will have
        # specified a distribution.
        rand_base_game_cards = BaseGame.kingdom_cards.shuffle
        rand_intrigue_cards = Intrigue.kingdom_cards.shuffle
        rand_seaside_cards = Seaside.kingdom_cards.shuffle
        rand_prosperity_cards = Prosperity.kingdom_cards.shuffle
        rand_hinterlands_cards = Hinterlands.kingdom_cards.shuffle

        pile_id = 0
        [:base_game, :intrigue, :seaside, :prosperity, :hinterlands].each do |set|
          (0...send("num_#{set}_cards").to_i).each do |ix|
            pile_id += 1
            send("pile_#{pile_id}=", eval("rand_#{set}_cards")[ix].name)
          end
        end
      else
        # User chose a totally random distibution over specified sets.
        valid_cards = []

        [BaseGame, Intrigue, Seaside, Prosperity, Hinterlands].each do |set|
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
    if not random_select.to_i == 1
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

  def total_cards_10
    if random_select.to_i == 1 && specify_distr.to_i == 1
      sum = [BaseGame, Intrigue, Seaside, Prosperity, Hinterlands].inject(0) {|total, exp| total + self.send("num_#{exp.name.underscore}_cards").to_i}
      if sum != 10
        errors[:base] << "Number of cards from each set must sum to 10."
      end
    end
  end

  def some_sets_present
    if random_select.to_i == 1 && specify_distr.to_i == 0
      if [BaseGame, Intrigue, Seaside, Prosperity, Hinterlands].all? {|set| self.send("#{set.name.underscore}_present") == 0}
        errors[:base] << "Must select at least one set."
      end
    end
  end

  def normalise_inputs
    self.random_select = self.random_select.to_i
    self.specify_distr = self.specify_distr.to_i
    self.num_base_game_cards = self.num_base_game_cards.to_i
    self.num_intrigue_cards = self.num_intrigue_cards.to_i
    self.num_seaside_cards = self.num_seaside_cards.to_i
    self.num_prosperity_cards = self.num_prosperity_cards.to_i
    self.num_hinterlands_cards = self.num_hinterlands_cards.to_i
    self.base_game_present = self.base_game_present.to_i
    self.intrigue_present = self.intrigue_present.to_i
    self.seaside_present = self.seaside_present.to_i
    self.prosperity_present = self.prosperity_present.to_i
    self.hinterlands_present = self.hinterlands_present.to_i
  end

  def init_facts
    self.facts ||= Hash.new
  end

  def make_piles
    # Prepare to add Platinum and Colony cards if the user (or the rules) say we should
    test_pile = piles_array[rand(10)]
    using_plat_col = false
    if plat_colony == "yes" ||
        (plat_colony == "rules" && test_pile.match(/(.*)::/)[1] == "Prosperity")
      using_plat_col = true
    end

    # Create the piles in order, so that the common cards appear first, then the Kingdom
    # Cards sorted by cost. Update their position fields
    posn = 0
    %w<Estate Duchy Province>.each do |vic|
      piles.create!(:card_type => "BasicCards::#{vic}", :position => posn)
      posn += 1
    end
    if using_plat_col
      piles.create!(:card_type => "Prosperity::Colony", :position => posn)
      posn += 1
    end
    %w<Copper Silver Gold>.each do |treas|
      piles.create!(:card_type => "BasicCards::#{treas}", :position => posn)
      posn += 1
    end
    if using_plat_col
      piles.create!(:card_type => "Prosperity::Platinum", :position => posn)
      posn += 1
    end
    piles.create!(:card_type => "BasicCards::Curse", :position => posn)
    posn += 1

    sorted_piles = piles_array.sort do |a_str,b_str|
      a = a_str.constantize
      b = b_str.constantize
      (a.cost == b.cost) ? a.name <=> b.name : a.cost <=> b.cost
    end
    sorted_piles.each_with_index do |typ, ix|
      piles.create(:card_type => typ, :position => posn + ix)
    end
  end

  def log_creation
    histories.create!(:event => "Game #{name} created.",
                     :css_class => "meta game_create")

    chats.create!(:non_ply_name => "Game", :turn => 0, :statement => "Welcome to '#{name}'!")
  end

  def age_oldest
    while Game.count > 5
      oldest_finished = Game.find(:first,
                                  :conditions => ["state = 'ended' and (end_time is null or end_time < ?)", 3.days.until(Time.now)],
                                  :order => "end_time, id")
      if oldest_finished
        oldest_finished.destroy
      else
        break
      end
    end
  end
end
