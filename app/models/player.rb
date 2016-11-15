class Player < ActiveRecord::Base

  include GamesHelper
  include CardsHelper
  extend FauxField

  @@to_email = {}
  cattr_accessor :to_email

  belongs_to :game
  belongs_to :user

  has_many :journals
  has_many :chats, -> { order(:created_at) }, :dependent => :delete_all
  has_one :settings, :dependent => :destroy
  accepts_nested_attributes_for :settings

  # Things that used to be database fields and relations
  faux_field :cash, :vp_chips, [:state, PlayerState.new]
  faux_field :num_actions, :num_buys
  validates :user_id, :uniqueness => {:scope => 'game_id'}
  validates :seat, :uniqueness => {:scope => 'game_id', :allow_nil => true}
  after_create :init_player
  after_initialize :init

  def init
    @cards = Collections::CardsCollection.new
    @state = PlayerState.new
    @state.init_fields
  end

  def name
    user.name
  end

  def questions
    game.questions.select { |q| q.actor == self }
  end

  def cards
    game.cards.belonging_to_player(self)
  end

  def start_game
    # To start the game, each player needs a deck of 7 copper and 3 estate,
    # 5 of which are in hand.
    card_order = ["BasicCards::Copper"] * 7 + ["BasicCards::Estate"] * 3
    card_order.shuffle!

    hand_order = card_order[0,5]
    deck_order = card_order[5,10]

    hand_order.each_with_index do |card_type, ix|
      game.cards << to_class(card_type).new(game: game,
                                        player: self,
                                        location: "hand",
                                        position: ix)
    end

    deck_order.each_with_index do |card_type, ix|
      game.cards << to_class(card_type).new(game: game,
                                        player: self,
                                        location: "deck",
                                        position: ix)
    end
  end

  def determine_controls
    return Hash.new([]) if questions.blank?

    self.reload
    controls = Hash.new([])
    questions.each do |action|
      if action.object == self
        case action.method
        when :play_action
          controls[:hand] += [{type: :button,
                               text: "Play",
                               nil_action: {text: "Leave Action Phase",
                                            journal: "#{name} played no further actions."},
                               journals: cards.hand.each_with_index.map { |c, ix| "#{name} played #{c.readable_name} (#{ix})." if c.is_action? },
                               css_class: 'play'
                              }]
        when :play_treasure
          nil_actions = []
          if cards.hand.any? { |card| card.is_treasure? && !card.is_special? }
            card_list = cards.hand.each_with_index.map { |c, ix| "#{c.readable_name} (#{ix})" if c.is_treasure? && !c.is_special? }
            nil_actions << {text: 'Play Simple Treasures',
                            journal: "#{name} played #{card_list.compact.join(', ')} as treasures."}
          end
          nil_actions << {text: 'Stop Playing Treasures',
                          journal: "#{name} played no further treasures.",
                          confirm: true}
          controls[:hand] += [{type: :checkboxes,
                               choice_text: "Play",
                               button_text: 'Play selected',
                               nil_action: nil_actions,
                               journal_template: "#{name} played {{cards}} as treasures.",
                               journals: cards.hand.each_with_index.map { |c, ix| {k: :cards, v: "#{c.readable_name} (#{ix})"} if c.is_treasure?},
                               css_class: 'play-treasure'
                              }]
        when :buy
          piles = game.piles.each_with_index.map do |pile, ix|
            if game.facts[:contraband] && game.facts[:contraband].include?(pile.card_type)
              nil
            elsif pile.card_type == "Prosperity::GrandMarket" && !cards.in_play.of_type("BasicCards::Copper").empty?
              nil
            elsif pile.cost > cash || pile.cards.empty?
              nil
            else
              "#{name} bought #{pile.cards[0].readable_name} (#{ix})."
            end
          end
          controls[:piles] += [{:type => :button,
                                :text => "Buy",
                                :nil_action => {text: 'Buy no more',
                                                journal: "#{name} bought no more cards"},
                                journals: piles
                              }]
        when 'choose_sot_card'
          # We've peeked at the cards we can choose between
          controls[:peeked] += [{type: :button,
                                  action: :choose_sot_card,
                                  text: 'Choose',
                                  params: {},
                                  cards: [true] * cards.peeked.count,
                                  pa_id: action.id
                                }]
        end
      elsif action.method != :start_game
        tmp_ctrls = Hash.new([])
        action.object.determine_controls(self, tmp_ctrls, action)
        tmp_ctrls.each do |key, ctrl_array|
          controls[key] ||= []
          controls[key] += ctrl_array
        end
      end
    end

    return controls
  end

  def play_action(journal, actor, check: false)
    match = /#{name} played (.*)/.match(journal.event)
    ok = actor == self && match
    if !ok || check
      return ok
    end

    # Check we still have an action available
    if num_actions < 1
      journal.errors.add(:base, 'No available actions remaining')
      return true
    end

    # Check for playing nothing
    card_req = match.captures[0].sub(/\.*$/, '')
    if card_req == 'no further actions'
      self.num_actions = 0
      game.treasure_step = true
      return true
    end

    # Check we have the specified card in hand
    ret, card = find_card_for_journal(cards.hand, card_req)
    if ret != :ok
      journal.card_error ret
      return true
    end

    # Check the specified card is an action
    if !card.is_action?
      journal.card_error :wrong
      journal.errors.add(:base, 'Specified card is not an action')
      return true
    end

    # Play the card
    self.num_actions -= 1
    begin
      card.play
    rescue ArgumentError
      raise
      journal.errors.add(:base, 'Card not updated to journal system')
    end

    if num_actions == 0
      game.treasure_step = true
    end

    true
  end

  def play_treasure(journal, actor, check: false)
    match = /#{name} played (.*) treasures/.match(journal.event)
    ok = actor == self && match
    if !ok || check
      return ok
    end

    # Check for playing nothing
    card_req = match.captures[0]
    if card_req == 'no further'
      game.treasure_step = false
      return true
    end

    # Split out the card strings requested
    card_req.sub!(/\s* as/, '')
    card_strings = card_req.split(',').map(&:strip)

    # Check we have the specified cards in hand
    card_arr = card_strings.map do |card_s|
      ret, card = find_card_for_journal(cards.hand, card_s)
      if ret != :ok
        journal.card_error ret
        return true
      end
      card
    end

    # Check the specified cards are all treasures
    if !card_arr.all?(&:is_treasure?)
      journal.card_error :wrong
      journal.errors.add(:base, 'Specified card is not a treasure')
      return true
    end

    # Play the cards
    ok = true
    cash_added = 0
    card_arr.each do |card|
      begin
        cash_added += card.play_treasure
      rescue ArgumentError
        ok = false
        journal.errors.add(:base, "Card #{card.readable_name} not updated to journal system")
      end
    end

    if ok
      journal.add_history(event: "Cash added: #{cash_added}. Total cash: #{cash}.",
                          css_class: "player#{seat}")
    end

    ok
  end

  def buy(journal, actor, check: false)
    match = /#{name} bought (.*)/.match(journal.event)
    ok = actor == self && match
    if !ok || check
      return ok
    end

    # Check we still have a buy available
    if num_buys < 1
      journal.errors.add(:base, 'No buys remaining')
      return true
    end

    # Check for buying nothing
    card_req = match.captures[0].sub(/\.*$/, '')
    if card_req == 'no more cards'
      self.num_buys = 0
      return true
    end

    # Check we can find the specified card in piles
    ret, card = find_card_for_journal(game.supply_cards, card_req)
    if ret != :ok
      journal.card_error ret
      return true
    end

    # Check the specified card costs no more than our current cash
    if card.cost > cash
      journal.card_error :wrong
      journal.errors.add(:base, 'Specified card is too expensive')
      return true
    end

    # Buy the card.
    # TODO: Trigger "on-buy" here

    # Pay the cash, use up a buy
    self.cash -= card.cost
    self.num_buys -= 1

    # Gain the card
    actor.gain(card: card, journal: journal)
    true
  end

  def end_turn
    game.add_history(:event => "#{name} ended their turn.",
                     :css_class => "player#{seat} end_turn")

    clean_up
    draw_hand
    next_turn
  end

  def clean_up
    # Move all cards in Play or Hand to Discard
    cards.hand.each do |card|
      card.discard
    end
    cards.in_play.each do |card|
      card.discard_from_play
    end
  end

  def draw_hand
    # Draw a new hand of 5 cards (or 3 if they played Outpost) ...
    if state.outpost_queued
      draw_cards(3)
    else
      draw_cards(5)
    end
  end

  def next_turn
    # ... nil off the turn parameters for this player ...
    self.cash = nil
    self.num_actions = nil
    self.num_buys = nil

    # ... stop here if the game's ended ...
    if !game.check_game_end
      # ... and ask the next player to start their turn.
      # (or this player if Outpost is letting them take another).
      if state.outpost_queued && !state.outpost_prevent
        next_seat = seat
        state.outpost_prevent = true
      else
        next_seat = (seat + 1) % game.players.length
        state.outpost_prevent = false
      end

      game.players[next_seat].start_turn
    end
  end

  def start_turn
    # Start this player's turn. They should already have a hand.

    # Set up cash and action-buy counts
    self.cash = 0
    self.num_actions = 1
    self.num_buys = 1

    # Advance the turn counter when the first player starts their turn.
    if seat == 0
      game.turn_count += 1
    end

    # Tell the game it's in the Action phase
    game.turn_phase = Game::TurnPhases::ACTION
    game.treasure_step = false
    game.current_turn_player = self

    game.reset_facts
    state.reset_fields

    game.add_history(event: "#{name}'s turn #{game.turn_count} started.",
                     css_class: "player#{seat} start_turn")

    # See whether multiple start-of-turn cards, including Prince, need to go off at once.
    # If so, we'll add an action to queue them up.
    #
    # This is a hack, but it should get a lot nicer with a proper notification framework.
    princes = cards.in_location('prince').of_type('PromoCards::Prince')
    princed = princes.map do |p|
      # Technically, a Prince in the prince location could be the Princed card of another Prince (o.O;)
      princed_id = p.state.andand[:princed_id]
      c = Card.find_by_id(princed_id)
      c.andand.location == 'prince' ? c : nil
    end.compact
    start_of_turn_cards = cards.enduring + princed
    if start_of_turn_cards.count > 1 && princed.present?
      # Add a callback to resolve the last start-of-turn card
      parent_action = parent_action.children.create!(expected_action: "player_last_sot_card;player=#{id}",
                                                      game: game)

      # Peek at the cards we can consider playing, so we can put some controls on them
      start_of_turn_cards.each { |c| c.peeked = true; c.save! }

      (start_of_turn_cards.count - 2).times do
        parent_action = parent_action.children.create!(expected_action: 'choose_sot_card',
                                                        text: 'Choose the next card to play at start of turn',
                                                        game: game,
                                                        player: self)

        # Between each pair of choice actions, we need to re-peek the cards because we have to unpeek
        # them in case the card we're playing needs to do peeking. Ugh.
        parent_action = parent_action.children.create!(expected_action: "player_repeek_sot_cards;player=#{id}",
                                                        game: game)
      end
      parent_action = parent_action.children.create!(expected_action: 'choose_sot_card',
                                                      text: 'Choose the first card to play at start of turn',
                                                      game: game,
                                                      player: self)
    else
      # Call any enduring cards to come into play
      cards.enduring.each do |card|
        game.histories.create!(:event => "#{name}'s #{card.class.readable_name} came off Duration.",
                              :css_class => "player#{seat} end_duration")
        card.end_duration(parent_action.reload)
      end

      # Invoke any cards the player has that act at turn-start
      cards.each do |card|
        #card.witness_turn_start(parent_action.reload)
      end
    end

    prompt_for_questions
  end

  # Called by the game when it has nothing left to ask about, to see if the player needs to act or buy
  def prompt_for_questions
    if num_actions > 0
      # Ask the question - play action
      game.turn_phase = Game::TurnPhases::ACTION
      game.ask_question(object: self, actor: self, method: :play_action, text: 'Play an action.')
    elsif game.treasure_step && cards.hand.any?(&:is_treasure?)
      game.turn_phase = Game::TurnPhases::BUY

      # Ask the question - play treasures
      game.ask_question(object: self, actor: self, method: :play_treasure, text: 'Play treasures.')
    elsif num_buys > 0
      # Just to be sure, force us out of treasure step
      game.turn_phase = Game::TurnPhases::BUY
      game.treasure_step = false

      # Ask the question - buy card
      game.ask_question(object: self, actor: self, method: :buy, text: 'Buy.')
    else
      # Next turn
      game.turn_phase = Game::TurnPhases::CLEAN_UP
      end_turn
    end
  end

  # Handle the user choosing a card to play at the start of turn.
  def choose_sot_card(params)
    # Checks, including retrieving the action.
    this_act, response = find_action(params[:pa_id])

    if this_act.nil?
      return response
    elsif (!params.include?(:card_index))
       return "Invalid parameters - must specify a card or nil_action"
    elsif ((params.include? :card_index) &&
           (params[:card_index].to_i < 0 ||
            params[:card_index].to_i > cards.peeked.length - 1))
      # Asked to buy an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # Find the chosen card, then unpeek all cards
    card = cards.peeked[params[:card_index].to_i]
    cards.peeked.each { |c| c.peeked = false; c.save! }

    # Remove this action, noting the parent
    parent_act = this_act.parent
    Game.current_act_parent = parent_act
    this_act.destroy

    # Handle the chosen card; if it's a duration, un-endure it. If it's princed,
    # invoke the start-turn method of its parent Prince.
    if card.location == 'enduring'
      game.histories.create!(:event => "#{name}'s #{card.class.readable_name} came off Duration.",
                            :css_class => "player#{seat} end_duration")
      card.end_duration(parent_act)
    else
      raise "Unexpected location #{card.location} for SOT card" unless card.location == 'prince'
      prince = cards.in_location('prince').of_type('PromoCards::Prince').detect { |p| p.state.andand[:princed_id] == card.id }
      raise "Princed card with no Prince" unless prince
      prince.witness_turn_start(parent_act)
    end

    "OK"
  end

  # Peek at the cards necessary for choosing the next start-of-turn card to play
  def repeek_sot_cards(params)
    princes = cards.in_location('prince').of_type('PromoCards::Prince')
    princed = princes.map do |p|
      c = Card.find_by_id(p.state[:princed_id])
      c.location == 'prince' ? c : nil
    end.compact
    (cards.enduring + princed).each { |c| c.peeked = true; c.save! }
  end

  # Play the last start-of-turn card
  def last_sot_card(params)
    repeek_sot_cards(params)

    # We want to just call choose_sot_card, but that needs the current action to exist, which it doesn't.
    # Create an action, for the sole purpose of passing it in.
    # This is just _wrong_.
    act = params[:parent_act].children.create!(expected_action: '', game: game, player: self)
    params[:pa_id] = act.id
    params[:card_index] = 0
    choose_sot_card(params)
  end

  # Grants the player the specified number of Actions
  def add_actions(num)
    # First, check that it's the player's turn
    raise RuntimeError.new("Not Player #{id}'s turn") unless cash

    self.num_actions += num
  end

  # Grants the player the specified number of Buys
  def add_buys(num)
    # First, check that it's the player's turn
    raise RuntimeError.new("Not Player #{id}'s turn") unless cash

    self.num_buys += num
  end

  # Grants the player the specified number of Buys, and returns an action suitable
  # for hanging more things off.
  def add_buysold(num, parent_act)
    # Add _num_ buys to the Player.
    # First, check that it's the player's turn
    raise RuntimeError.new("Not Player #{id}'s turn") unless cash

    # Store off the parent_act we've been given - we may want to return it later
    orig_act = parent_act
    return_orig = false

    # Need to step back and find the lowest Buy action, which must belong to the
    # player
    until parent_act.expected_action == "buy"
      parent_act = parent_act.parent

      # Had to step upwards, so should return the original parent_act
      return_orig = true
    end
    if parent_act.player != self
      raise RuntimeError.new("PendingAction #{parent_act.id} doesn't belong to Player #{id}")
    end

    # Now create the specified number of Buys
    1.upto(num) do |n|
      parent_act = parent_act.insert_child!(:expected_action => "buy",
                                            :player => self,
                                            :game => game)
    end

    save!

    return (return_orig ? orig_act : parent_act)
  end

  # Add cash and save.
  def add_cashold(num)
    self.cash += num
    save!
  end

  def add_vpsold(num)
    self.vp_chips += num
    self.score += num
    save!
  end

  # Draw, or attempt to, the specified number of cards, shuffling the discard
  # pile under the deck if needed.
  #
  # Return the array of cards actually drawn
  def draw_cards(num, reason = nil)
    cards_drawn = []

    if nil==reason
      reason = ""
    end

    shuffle_point = cards.deck.size
    if cards.deck.size < num && !cards.in_discard.empty?
      shuffle_discard_under_deck(:log => shuffle_point == 0)
    end

    deck_cards = cards.deck
    (0..[num, cards.deck.size].min - 1).each do |n|
      card = deck_cards[n]
      card.position = cards.hand.length
      card.location = "hand"
      cards_drawn << card
    end

    renum(:deck)

    if cards_drawn.empty?
      game.add_history(:event => "#{name} drew no cards#{reason}.",
                            :css_class => "player#{seat} card_draw")
    else
      # Some number of cards drawn, revealing information and therefore blocking journal editing before it
      game.apply_journal_block

      drawn_string = "[#{id}?"
      if shuffle_point > 0 && shuffle_point < cards_drawn.length
        drawn_string << cards_drawn[0,shuffle_point].join(', ')
        drawn_string << "|#{shuffle_point} card#{shuffle_point == 1 ? '' : 's'}]"
        drawn_string << ", shuffled their discards, then drew [#{id}?"
        drawn_string << cards_drawn[shuffle_point, cards_drawn.length].join(', ')
        drawn_string << "|#{cards_drawn.length - shuffle_point} card#{cards_drawn.length - shuffle_point == 1 ? '' : 's'}]"
      else
        drawn_string << "#{cards_drawn.join(', ')}|#{cards_drawn.length} card#{cards_drawn.length == 1 ? '' : 's'}]"
      end

      game.add_history(:event => "#{name} drew #{drawn_string}#{reason}.",
                            :css_class => "player#{seat} card_draw #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_drawn.length)}")
    end

    if cards_drawn.length < num
      excess = num - cards_drawn.length
      game.add_history(:event => "#{name} tried to draw #{excess} more card#{'s' unless excess == 1}#{reason}, but their deck was empty.",
                            :css_class => "player#{seat} card_draw")
    end

    return cards_drawn
  end

  # Reveal the top _num_ cards of the Player's deck, by marking the Card objects
  # as Revealed.
  #
  # Processing will be very similar to draw_cards, but the cards never leave the
  # deck
  def reveal_from_deck(num, options = {})
    silent = options[:silent]

    # We need to force the deck and discard arrays to be populated
    cards(true)
    cards_revealed = []

    shuffle_point = cards.deck.size
    if cards.deck.size < num and not cards.in_discard.empty?
      shuffle_discard_under_deck(:log => shuffle_point == 0)
    end

    cards.deck[0, num].each do |card|
      card.revealed = true
      cards_revealed << card.readable_name
      card.save
    end

    if cards_revealed.empty?
      game.histories.create!(:event => "#{name} revealed no cards.",
                            :css_class => "player#{seat} card_reveal") unless silent
    else
      rev_string = ""
      if shuffle_point > 0 && shuffle_point < cards_revealed.length
        rev_string << cards_revealed[0,shuffle_point].join(', ')
        rev_string <<  ", shuffled their discards, then revealed "
        rev_string << cards_revealed[shuffle_point, cards_revealed.length].join(', ')
      else
        rev_string << cards_revealed.join(', ')
      end
      game.histories.create!(:event => "#{name} revealed #{rev_string}.",
                            :css_class => "player#{seat} card_reveal #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_revealed.length)}"
                            ) unless silent
    end
    if cards_revealed.length < num
      excess = num - cards_revealed.length
      game.histories.create!(:event => "#{name} tried to reveal #{excess} more cards, but their deck was empty.",
                            :css_class => "player#{seat} card_reveal") unless silent
    end
    save!

    return cards_revealed
  end

  # Peek at the top or bottom _num_ cards of the Player's deck, by marking the Card objects
  # as Peeked.
  #
  # This is nearly identical to reveal_from_deck
  def peek_at_deck(num, t_or_b = :top)
    raise "Bad parameters to peek" unless [:top, :bottom].include? t_or_b
    # We need to force the deck and discard arrays to be populated
    cards(true)
    cards_peeked = []

    shuffle_point = cards.deck.size
    if cards.deck.size < num and not cards.in_discard.empty?
      shuffle_discard_under_deck(:log => shuffle_point == 0)
    end

    if t_or_b == :top
      range = (0..num-1)
    else
      range = (-num..-1)
    end

    (cards.deck[range] || []).each do |card|
      card.peeked = true
      cards_peeked << card.readable_name
      card.save
    end

    if cards_peeked.empty?
      game.histories.create!(:event => "#{name} looked at no cards.",
                            :css_class => "player#{seat} card_peek")
    else
      peeked_string = "[#{id}?"
      if shuffle_point > 0 && shuffle_point < cards_peeked.length
        peeked_string << cards_peeked[0,shuffle_point].join(', ')
        peeked_string << "|#{shuffle_point} card#{shuffle_point == 1 ? '' : 's'}]"
        peeked_string << ", shuffled their discards, then saw [#{id}?"
        peeked_string << cards_peeked[shuffle_point, cards_peeked.length].join(', ')
        peeked_string << "|#{cards_peeked.length - shuffle_point} card#{cards_peeked.length - shuffle_point == 1 ? '' : 's'}]"
      else
        peeked_string << "#{cards_peeked.join(', ')}|#{cards_peeked.length} card#{cards_peeked.length == 1 ? '' : 's'}]"
      end
      game.histories.create!(:event => "#{name} saw #{peeked_string} on the " +
                                      "#{t_or_b == :top ? 'top' : 'bottom'} of their deck.",
                            :css_class => "player#{seat} card_peek #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_peeked.length)}")
    end

    if cards_peeked.length < num
      excess = num - cards_peeked.length
      game.histories.create!(:event => "#{name} tried to look at #{excess} more cards, but their deck was empty.",
                            :css_class => "player#{seat} card_peek")
    end
    save!
    return cards_peeked
  end

  def peeked_card_ixes
    return (0..(cards(true).deck.length - 1)).select {|ix| cards.deck[ix].peeked}
  end

  def other_players
    # Return an array of the other players in the game, in seat order from self
    others = game.players.reject {|p| p == self}
    others = others.sort_by { |p| (p.seat - seat) % game.players.length } if seat
    others
  end

  def next_player
    # Return the player in the next seat.
    game.players[(seat + 1) % game.players.length]
  end

  def prev_player
    # Return the player in the next seat.
    game.players[(seat - 1) % game.players.length]
  end

  def renum(location, hole_at=nil)
    set = cards.in_location(location.to_s)
    set.each_with_index do |card, ix|
      card.position = ix

      # Leave a gap at the specified offset, allowing cards to "slot in" to
      # the deck
      card.position += 1 if hole_at && ix >= hole_at
    end
  end

  def shuffle_discard_under_deck(options = {})
    options = {:log => true}.merge(options)
    # Take all the cards in the discard pile and put them, in random order,
    # at the end of the deck array.
    renum(:deck)
    cards.in_discard.shuffle.each do |card|
      card.location = "deck"
      card.position = cards.deck.count
    end

    if options[:log]
      game.add_history(:event => "#{name} shuffled their discard pile.",
                       :css_class => "player#{seat} shuffle")
    end
  end

  def calc_score
    self.score ||= vp_chips || 0
    self.score += self.cards.inject(0) {|sum, card| sum + card.points}
    save!
  end

  def cards_for_decklist(html = true)
    deck = cards.unscoped.where(:player_id => self).count(:group => "type").sort do |gp_a,gp_b|
      type_a = gp_a[0]
      type_b = gp_b[0]
      a = cards.find_by_type(type_a)
      b = cards.find_by_type(type_b)

      if type_a == type_b
        0
      elsif a.is_victory? && !b.is_victory?
        -1
      elsif b.is_victory? && !a.is_victory?
        1
      elsif a.is_victory? && b.is_victory?
        b.points <=> a.points
      elsif type_a == "BasicCards::Curse" && type_b != "BasicCards::Curse"
        -1
      elsif type_b == "BasicCards::Curse" && type_a != "BasicCards::Curse"
        1
      else
        0
      end
    end

    deck_list = []

    deck.each_with_index do |pair, ix|
      type, num = *pair
      rep = cards.find_by_type(type)
      css_class = ""
      points = nil
      if rep.is_victory?
        css_class = "victory-text"
        points = rep.points
      elsif type == "BasicCards::Curse"
        css_class = "curse-text"
        points = -1
      end

      deck_list[ix] = {:type => type, :num => num, :css_class => css_class, :points => points}
    end

    vps = if self.vp_chips != 0 && html
      "<span class='victory-text'>#{vp_chips} VP chip#{vp_chips == 1 ? "" : "s"}</span>, "
    elsif self.vp_chips != 0
      "#{vp_chips} VP chips, "
    else
      ""
    end

    list = if html
      deck_list.map do |det|
        "<span class='#{det[:css_class]}'>" +
          det[:type].constantize.readable_name +
          (det[:points] ? " (#{det[:points]} VP)" : "") +
          " x#{det[:num]}" +
        "</span>"
      end.join(', ')
    else
      deck_list.map do |det|
        det[:type].readable_name +
        (det[:points] ? " (#{det[:points]} VP)" : "") +
        " x#{det[:num]}"
      end.join(', ')
    end

    return vps + list
  end

  # This needs to handle gaining both from a pile, and of a specific card (as in Thief).
  # opts must contain either
  # :pile => <Pile object> or :card => <Card object>
  def gain(opts = {})
    raise "No :card or :pile to gain" unless (opts.include?(:card) || opts.include?(:pile))
    raise "Both :card and :pile given to gain" if (opts.include?(:card) && opts.include?(:pile))
    raise ":card supplied but not a Card" if (opts[:card] && !opts[:card].is_a?(Card))
    raise ":pile supplied but not a Pile" if (opts[:pile] && !opts[:pile].is_a?(Pile))
    raise "Object to be gained not in this game" if ((opts[:pile] && opts[:pile].game != game) ||
                                                      (opts[:card] && opts[:card].game != game))

    # Trip any cards that need to trigger before the gain to change the details of the gain
    # (as for, say, Nomad Camp)
    card_types = game.cards.map(&:class).uniq
    gain_params = {:gainer => self,
                   :card => opts[:card], # Can be nil
                   :pile => opts[:pile], # Can be nil
                   journal: opts[:journal],
                   :location => opts[:location] || 'discard',
                   :position => opts[:position] || 0}

    # TODO: Publish pre-gain event here

    pile = gain_params[:pile]
    card = gain_params[:card] || pile.cards[0]
    journal = gain_params[:journal]

    if pile.andand.empty?
      # Can't gain this card
      journal.add_history(:event => "#{name} couldn't gain a #{pile.card_class.readable_name}, as the pile was empty.",
                          :css_class => "player#{seat}")
      return
    end

    raise "Couldn't determine card to gain" if card.nil?
    raise "Card not in this game" if card.game != game

    journal.add_history(event: "#{name} gained #{card.readable_name}.",
                        css_class: "player#{seat} card_gain")
    # Move the chosen card to the chosen position.
    # Card#gain defaults to discard, -1
    #
    # Get the card to do it, so that we mint a fresh instance of infinite cards
    card.gain(self, journal, locn: gain_params[:location], posn: gain_params[:position])

  end

private

  def init_player
    if user && user.settings.nil?
      user.create_settings
    end

    create_settings!(user.settings.attributes.except('id', 'user_id'))
  end

  def find_action(action_id)
    pa = nil
    error = ""
    begin
      pa = PendingAction.find(action_id.to_i)

      pending_actions.active.reload
      if !pending_actions.active.include? pa
        error = "Not expecting you to #{pa.text} at this time"
        pa = nil
      end
    rescue ActiveRecord::RecordNotFound
      pa = nil
      error = "Sorry, no matching action could be found"
    end

    [pa, error]
  end

  def email_creator
    if game_id_changed? && self != game.players[0] && game.players[0].user.pbem?
      ply = game.players[0]
      @@to_email[ply.id] ||= {}
      @@to_email[ply.id][:player_joined] = [self]
    end
  end

end
