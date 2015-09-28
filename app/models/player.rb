class Player < ActiveRecord::Base

  include GamesHelper

  @@to_email = {}
  cattr_accessor :to_email

  belongs_to :game
  belongs_to :user

  has_many :cards

  has_many :pending_actions
  has_one :state, :class_name => "PlayerState", :dependent => :destroy
  has_many :chats, -> { order(:created_at) }, :dependent => :delete_all
  has_one :settings, :dependent => :destroy
  accepts_nested_attributes_for :settings

  validates :user_id, :uniqueness => {:scope => 'game_id'}
  validates :seat, :uniqueness => {:scope => 'game_id', :allow_nil => true}
  after_save :email_creator

  before_create do
    if user and user.settings.nil?
      user.create_settings
    end
    self.build_settings(user.settings.attributes.delete(:id))
    self.settings.user_id = nil
    self.settings.save!

    self.create_state

    self.score = 0
    self.vp_chips = 0
  end

  def name
    user.name
  end

  def start_game
    # To start the game, each player needs a deck of 7 copper and 3 estate,
    # 5 of which are in hand.
    card_order = ["BasicCards::Copper"] * 7 + ["BasicCards::Estate"] * 3
    card_order.shuffle!

    hand_order = card_order[0,5]
    deck_order = card_order[5,10]

    hand_order.each_with_index do |card_type, ix|
      to_class(card_type).create!("game_id" => game.id,
                                 "player_id" => id,
                                 "location" => "hand",
                                 "position" => ix)
    end

    deck_order.each_with_index do |card_type, ix|
      to_class(card_type).create!("game_id" => game.id,
                                 "player_id" => id,
                                 "location" => "deck",
                                 "position" => ix)
    end
  end

  def determine_controls
    self.reload
    controls = Hash.new([])
    pending_actions(true).active.each do |action|
      case action.expected_action
      when 'play_action'
        controls[:hand] += [{type: :button,
                             action: :play_action,
                             text: "Play",
                             nil_action: "Leave Action Phase",
                             cards: cards.hand.map{|card| card.is_action?},
                             pa_id: action.id,
                             css_class: 'play'
                            }]
      when 'play_treasure'
        have_simples = cards.hand.any? { |card| card.is_treasure? && !card.is_special? }
        controls[:hand] += [{type: :button,
                             action: :play_treasure,
                             text: "Play",
                             nil_action: [have_simples ? "Play Simple Treasures" : nil, 'Stop Playing Treasures'],
                             cards: cards.hand.map{|card| card.is_treasure?},
                             pa_id: action.id,
                             confirm_nil: [false, true],
                             css_class: 'play-treasure'
                            }]
      when 'buy'
        piles = game.piles.map do |pile|
          if game.facts[:contraband] && game.facts[:contraband].include?(pile.card_type)
            false
          elsif pile.card_type == "Prosperity::GrandMarket" && !cards.in_play.of_type("BasicCards::Copper").empty?
            false
          else
            (pile.cost <= cash and pile.cards.size != 0)
          end
        end
        controls[:piles] += [{type: :button,
                              action: :buy,
                              text: "Buy",
                              nil_action: "Buy no more",
                              piles: piles,
                              pa_id: action.id
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

      when /^resolve_([[:alpha:]]+::[[:alpha:]]+)([0-9]+)(?:_([[:alnum:]]*))?(;.*)?/
        card_type = $1
        card_id = $2
        substep = $3
        param_string = $4
        params = {}
        if param_string
          param_string.scan(/;([^;=]*)=([^;=]*)/) {|m| params[m[0].to_sym] = m[1]}
        end
        card = card_type.constantize.find(card_id)
        tmp_ctrls = Hash.new([])
        card.determine_controls(self, tmp_ctrls, substep, params)
        tmp_ctrls.each do |key, ctrl_array|
          ctrl_array.each {|ctrl| ctrl[:pa_id] = action.id}
          controls[key] ||= []
          controls[key] += ctrl_array
        end
      end
    end

    return controls
  end

  def play_action(params)
    # Checks, including retrieving the action.
    this_act, response = find_action(params[:pa_id])

    if this_act.nil?
      return response
    elsif (!params.include?(:nil_action) &&
           !params.include?(:card_index))
      return "Invalid parameters - must specify a card or nil_action"
    elsif ((params.include? :card_index) &&
           (params[:card_index].to_i < 0 ||
            params[:card_index].to_i > cards.hand.length - 1))
      # Asked to play an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif params.include?(:card_index) && !cards.hand[params[:card_index].to_i].is_action?
      # Asked to play an invalid card (not an action)
      return "Invalid request - card index #{params[:card_index]} is not an action"
    end

    # Checks are good. Remove the play_action action, noting the parent
    rc = "OK"
    parent_act = this_act.parent
    Game.current_act_parent = parent_act
    params[:this_act_id] = this_act.id
    this_act.destroy

    # Now process the action played
    if params[:nil_action]
      # Player has chosen to play no actions. Destroy all "Play Action" actions
      # and set their count of actions to 0.
      game.histories.create!(:event => "#{name} played no action.",
                            :css_class => "player#{seat} play_action")
      pending_actions.each do |act|
        act.destroy if act.expected_action == "play_action"
      end
    else
      card = cards.hand[params[:card_index].to_i]
      game.histories.create!(:event => "#{name} played #{card.class.readable_name}.",
                            :css_class => "player#{seat} play_action #{card.is_attack? ? 'play_attack' : ''}")
      rc = cards.hand[params[:card_index].to_i].play(parent_act)
    end

    #save!

    return rc
  end

  # If the player has any special treasures in hand, queue an action to play a treasure.
  # Likewise if the game has Grand Markets, Mints, Mandarins or Farmlands left to buy.
  # Otherwise, just play all the non-special treasures in hand.
  def play_treasures(params)
    return "Cash unexpectedly nil for Player #{id}" if cash.nil?

    # Game enters the "Buy" phase as soon as it hits play_treasures
    game.turn_phase = Game::TurnPhases::BUY
    game.save!

    immediate_cash = cash + cards.hand.select(&:is_treasure?).map{|c| c.cash || 0}.inject(0,&:+)
    quarries = cards.hand.of_type("Prosperity::Quarry").count

    gm_pile_card = game.cards.pile.of_type("Prosperity::GrandMarket").first
    mint_pile_card = game.cards.pile.of_type("Prosperity::Mint").first
    mandarin_pile_card = game.cards.pile.of_type("Hinterlands::Mandarin").first
    farmland_pile_card = game.cards.pile.of_type("Hinterlands::Farmland").first

    gm_blocking = gm_pile_card &&
                  immediate_cash >= gm_pile_card.cost - 2*quarries &&
                  !cards.hand.of_type("BasicCards::Copper").empty?
    mint_blocking = mint_pile_card &&
                    immediate_cash >= mint_pile_card.cost - 2*quarries
    mandarin_blocking = mandarin_pile_card &&
                        immediate_cash >= mandarin_pile_card.cost - 2*quarries
    farmland_blocking = farmland_pile_card && immediate_cash >= farmland_pile_card.cost

    if cards.hand.any? {|card| card.is_treasure?} &&
        (cards.hand.any? {|card| card.is_treasure? && card.is_special?} ||
          gm_blocking || mint_blocking || mandarin_blocking || farmland_blocking)
      # Need to ask the player about playing treasures. But queue up another copy of this
      # first, so that we re-check afterwards
      parent_act = params[:parent_act]
      parent_act.queue(:expected_action => "play_treasure",
                       :game => game,
                       :player => self).queue(
                      :expected_action => "player_play_treasures;player=#{id}",
                       :game => game)
    else
      # This branch handles a hand with no special treasures, and with no special buy piles,
      # including holding no treasures.
      auto_play_treasures(true)

      return "Played all treasures, then had some left!" if cards.hand.any? {|card| card.is_treasure?}
    end

    return "OK"
  end

  # Play all non-special treasures in hand.
  def auto_play_treasures(give_total)
    return "Cash unexpectedly nil for Player #{id}" if cash.nil?
    cards_played = []
    cards.hand.select {|card| card.is_treasure? && !card.is_special?}.each do |card|
      card.play_treasure(nil)
      self.cash += card.cash
      cards_played << card.class
    end
    split_string = self.buys <= 1 ? "" : ", split #{self.buys} ways"
    if cards_played.empty?
      game.histories.create!(:event => "#{name} played no Treasures. (#{self.cash} total#{split_string}).",
                            :css_class => "player#{seat} play_treasure")
    else
      if give_total
        game.histories.create!(:event => "#{name} played #{cards_played.map {|c| c.readable_name}.join(', ')} as Treasures. (#{self.cash} total#{split_string}).",
                              :css_class => "player#{seat} play_treasure")
      else
        game.histories.create!(:event => "#{name} played #{cards_played.map {|c| c.readable_name}.join(', ')} as Treasures.",
                              :css_class => "player#{seat} play_treasure")
      end
    end
    state.played_treasure = true
    state.save!
    save!
  end

  # Play a specific treasure from hand, or play all simple treasures, or stop playing.
  def play_treasure(params)
    return "Cash unexpectedly nil for Player #{id}" if cash.nil?
    # Unsurprisingly, this is much like play_action.
    # Checks, including retrieving the action.
    this_act, response = find_action(params[:pa_id])

    if this_act.nil?
      return response
    elsif (!params.include?(:nil_action) &&
           !params.include?(:card_index))
       return "Invalid parameters - must specify a card or nil_action"
    elsif ((params.include? :card_index) &&
           (params[:card_index].to_i < 0 ||
            params[:card_index].to_i > cards.hand.length - 1))
      # Asked to play an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif params.include?(:card_index) && !cards.hand[params[:card_index].to_i].is_treasure?
      # Asked to play an invalid card (not an treasure)
      return "Invalid request - card index #{params[:card_index]} is not a treasure"
    end

    # Checks are good.
    rc = "OK"

    # Remove the Play Treasure action, noting the parent
    parent_act = this_act.parent
    Game.current_act_parent = parent_act
    this_act.destroy

    if params[:card_index]
      # Player has chosen to play a specific treasure. Find it.
      card = cards.hand[params[:card_index].to_i]
      state.played_treasure = true
      state.save!

      return "Special treasure not defining how to play itself - please report to site owner" if (card.is_special? && !card.class.implements_instance_method?(:play_treasure))
      game.histories.create!(:event => "#{name} played #{card.class.readable_name}.",
                            :css_class => "player#{seat} play_treasure")
      rc = card.play_treasure(parent_act)

      if !card.is_special?
        # For normal treasures, we have to add the cash ourselves.
        self.cash += card.cash
        save!
      end
    else
      # One of the nil-actions chosen.
      if params[:nil_action] =~ /^Stop/
        # Player chose to stop playing treasures. Log, and destroy the parent action to
        # drop through to the Buy
        split_string = self.buys <= 1 ? "" : ", split #{self.buys} ways"
        if state.played_treasure
          game.histories.create!(:event => "#{name} has #{self.cash} total cash#{split_string}.",
                                :css_class => "player#{seat} play_treasure")
        else
          game.histories.create!(:event => "#{name} played no Treasures. (#{self.cash} total#{split_string}).",
                                :css_class => "player#{seat} play_treasure")
        end

        parent_act.destroy
      else
        # Player chose to play all their simple treasures.
        return "Don't appear to be Playing Simple, or Stopping" unless params[:nil_action] =~ /^Play/
        auto_play_treasures(false)
      end
    end

    return rc
  end

  def buy(params)
    # Checks, including retrieving the action.
    this_act, response = find_action(params[:pa_id])

    if this_act.nil?
      return response
    elsif (!params.include?(:nil_action) &&
           !params.include?(:pile_index))
       return "Invalid parameters - must specify a card or nil_action"
    elsif ((params.include? :pile_index) &&
           (params[:pile_index].to_i < 0 ||
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to buy an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    end

    pile = game.piles[params[:pile_index].to_i] if params[:pile_index]

    if pile && pile.cost > cash
      # Asked to buy an invalid card (too expensive)
      return "Invalid request - card #{pile.card_type.readable_name} is too expensive"
    elsif pile && pile.cards.empty?
      return "Invalid request - pile #{pile.card_type.readable_name} is empty"
    elsif pile && game.facts[:contraband] && game.facts[:contraband].include?(pile.card_type)
      # Asked to buy Contraband
      return "Invalid request - card #{pile.card_type.readable_name} is Contraband this turn"
    elsif pile && pile.card_type == "Prosperity::GrandMarket" && !cards.in_play.of_type("BasicCards::Copper").empty?
      return "Invalid request - can't buy Grand Market with Copper in play"
    end

    # Checks are good.

    # If the player is buying (rather than declining), create the log here. This
    # fixes a bug with Peddler, which needs the "buy" action still around to get its cost right.
    if !params[:nil_action]
      game.histories.create!(:event => "#{name} bought " +
                                  "#{pile.card_class.readable_name} for #{pile.cost}.",
                            :css_class => "player#{seat} buy")
    end

    # Remove the Buy action, noting the parent
    parent_act = this_act.parent
    Game.current_act_parent = parent_act
    this_act.destroy

    # Now process the Buy
    if params[:nil_action]
      # Player has chosen to Buy nothing. Destroy all "Buy" actions
      # and set their count of buys to 0.
      game.histories.create!(:event => "#{name} bought nothing.",
                            :css_class => "player#{seat} buy")
      pending_actions.each do |act|
        act.destroy if act.expected_action == "buy"
      end
    else
      # Process the Buy.

      # Subtract the cost from the player's cash
      self.cash -= pile.cost

      # Queue up a request for the player to gain the chosen card (assuming it's still there)
      if !pile.cards(true).empty?
        parent_act = gain(parent_act, :pile => pile)
      end

      # Trip any cards that need to trigger on buy, to occur before the gain
      card_types = game.cards.unscoped.select('distinct type').map(&:type).map(&:constantize)
      buy_params = {:buyer => self, :pile => pile, :parent_act => parent_act}
      card_types.each do |type|
        if type.respond_to?(:witness_buy)
          new_pa = type.witness_buy(buy_params)
          if new_pa.instance_of?(PendingAction)
            parent_act = new_pa
          end
        end
      end

    end

    save!

    return "OK"
  end

  def do_gain(params)
    # Called to move a card, possibly from a pile, to this player
    parent_act = params[:parent_act]
    pile_id = params[:pile_id]
    card_id = params[:card_id]
    pile = pile_id && Pile.find(pile_id)
    raise "Pile not in this game" if pile && (pile.game != game)

    if pile.andand.empty?
      # Can't gain this card
      game.histories.create!(:event => "#{name} couldn't gain a #{pile.card_class.readable_name}, as the pile was empty.",
                            :css_class => "player#{seat}")
      return
    end

    card = (card_id && Card.find(card_id)) || (pile && pile.cards[0])
    raise "Couldn't determine card to gain" if card.nil?
    raise "Card not in this game" if card.game != game
    location = params[:location]
    position = params[:position].to_i

    asking = false

    # Trip any cards that need to trigger on gain. They are allowed to modify
    # :location and :position through the params hash
    card_types = game.cards.unscoped.select('distinct type').map(&:type).map(&:constantize)
    gain_params = {:gainer => self,
                   :card => card,
                   :pile => pile, # Can be nil
                   :parent_act => parent_act,
                   :this_act_id => params[:this_act_id],
                   :location => location,
                   :position => position}
    card_types.each do |type|
      if type.respond_to?(:witness_gain)
        ask = type.witness_gain(gain_params)
        asking ||= ask
      end
    end

    return if asking

    # Move the chosen card to the chosen position.
    # Card#gain defaults to discard, -1
    #
    # Get the card to do it, so that we mint a fresh instance of infinite cards
    card.gain(self, parent_act, gain_params[:location], gain_params[:position])

  end

  def end_turn(params)
    # Check the player doesn't have any pending actions left
    if !pending_actions.empty?
      return "You unexpectedly have actions pending when ending turn"
    end

    game.histories.create!(:event => "#{name} ended their turn.",
                          :css_class => "player#{seat} end_turn")

    # Game is now in the clean-up phase
    game.turn_phase = Game::TurnPhases::CLEAN_UP
    game.save!

    # Explode the rest of end_turn's actions. Lastly, start the next turn to ensure we have a root action
    if params[:parent_act]
      parent_act = params[:parent_act].children.create!(:expected_action => "player_next_turn;player=#{id}",
                                                       :game => game)
    else
      parent_act = game.pending_actions.create!(:expected_action => "player_next_turn;player=#{id}",
                                               :game => game)
    end

    parent_act = parent_act.children.create!(:expected_action => "player_draw_hand;player=#{id}",
                     :game => game)
    parent_act = parent_act.children.create!(:expected_action => "player_clean_up;player=#{id}",
                     :game => game)

    cards.in_location('prince').of_type('PromoCards::Prince').each do |prince|
      # Add an action to set the action aside again, just before clean-up
      parent_act.children.create!(:expected_action => "resolve_#{prince.class}#{prince.id}_trigger",
                                   :game => game)
    end

    return "OK"
  end

  def clean_up(params)
    # Move all cards in Play or Hand to Discard
    # Force a reload of all affected areas
    cards(true).in_discard

    cards.hand.each do |card|
      card.discard
    end
    cards.in_play.each do |card|
      card.discard_from_play(params[:parent_act])
    end
  end

  def draw_hand(params)
    # Draw a new hand of 5 cards (or 3 if they played Outpost) ...
    if state.outpost_queued
      draw_cards(3)
    else
      draw_cards(5)
    end
  end

  def next_turn(params)
    # ... nil off the Cash parameter for this player ...
    self.cash = nil
    save!

    # ... stop here if the game's ended ...
    if not game.check_game_end
      # ... and ask the next player to start their turn.
      # (or this player if Outpost is letting them take another).
      if state.outpost_queued && !state.outpost_prevent
        next_seat = seat
        state.outpost_prevent = true
      else
        next_seat = (seat + 1) % game.players.length
        state.outpost_prevent = false
      end
      state.save!

      rc = game.players[next_seat].start_turn
    else
      rc = "OK"
    end

    return rc
  end

  def start_turn
    # Start this player's turn. They should already have a hand.

    # Set up cash and create their pending_actions
    self.cash = 0

    save!

    # Create the root action, to end the turn.
    root_action = game.pending_actions.create!(:expected_action => "player_end_turn;player=#{id}",
                                              :game => game,
                                              :player => nil)

    # Now queue up playing an action, playing treasures and buying a card
    root_action.queue(:expected_action => "play_action",
                      :game => game,
                      :player => self).queue(
                     :expected_action => "player_play_treasures;player=#{id}",
                      :game => game,
                      :player => nil).queue(
                     :expected_action => "buy",
                      :game => game,
                      :player => self)
    parent_action = pending_actions.active.first
    raise "Unexpected action at start of turn" unless parent_action.expected_action == "play_action"

    # Advance the turn counter when the first player starts their turn.
    if seat == 0
      game.reload.turn_count += 1
    end

    # Tell the game it's in the Action phase
    game.turn_phase = Game::TurnPhases::ACTION
    game.save!

    game.reset_facts
    state(true).reset_fields

    game.histories.create!(:event => "#{name}'s turn #{game.turn_count} started.",
                          :css_class => "player#{seat} start_turn")

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
        card.witness_turn_start(parent_action.reload)
      end
    end

    return "OK"
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

  # Grants the player the specified number of Actions, and returns an action suitable
  # for hanging more things off.
  def add_actions(num, parent_act)
    # Add _num_ actions to the Player.
    # First, check that it's the player's turn
    raise RuntimeError.new("Not Player #{id}'s turn") unless cash

    # Store off the parent_act we've been given - we may want to return it later
    orig_act = parent_act
    return_orig = false

    # We should hang the actions off the lowest "play_action" or "play_treasures"
    # action, which must belong to or refer to this player
    until parent_act.expected_action =~ /^(play_action)|(play_treasures)/ do
      parent_act = parent_act.parent

      # Had to step upwards, so should return the original parent_act
      return_orig = true
    end
    if !(parent_act.player == self ||
            (parent_act.player.nil? && parent_act.expected_action =~ /;player=#{id}/))
      raise RuntimeError.new("PendingAction #{parent_act.id} doesn't belong to Player #{id}")
    end

    # Now create the specified number of actions
    1.upto(num) do |n|
      parent_act = parent_act.insert_child!(:expected_action => "play_action",
                                            :player => self,
                                            :game => game)
    end

    save!

    return (return_orig ? orig_act : parent_act)
  end

  # Grants the player the specified number of Buys, and returns an action suitable
  # for hanging more things off.
  def add_buys(num, parent_act)
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
  def add_cash(num)
    self.cash += num
    save!
  end

  def add_vps(num)
    self.vp_chips += num
    self.score += num
    save!
  end

  # Draw, or attempt to, the specified number of cards, shuffling the discard
  # pile under the deck if needed.
  #
  # Return the array of cards actually drawn
  def draw_cards(num, reason = nil)
    # We need to force the deck, hand and discard arrays to be populated
    cards(true)
    cards_drawn = []

    if nil==reason
      reason = ""
    end

    shuffle_point = cards.deck.size
    if cards.deck.size < num and not cards.in_discard.empty?
      shuffle_discard_under_deck(:log => shuffle_point == 0)
    end

    (0..[num, cards.deck.size].min - 1).each do |n|
      card = cards.deck.shift
      if cards.hand.empty?
        card.position = 0
      else
        card.position = cards.hand[-1].position + 1
      end
      cards.hand << card
      card.location = "hand"
      cards_drawn << card
      card.save
    end

    renum(:deck)

    if cards_drawn.empty?
      game.histories.create!(:event => "#{name} drew no cards#{reason}.",
                            :css_class => "player#{seat} card_draw")
    else
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

      game.histories.create!(:event => "#{name} drew #{drawn_string}#{reason}.",
                            :css_class => "player#{seat} card_draw #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_drawn.length)}")
    end

    if cards_drawn.length < num
      excess = num - cards_drawn.length
      game.histories.create!(:event => "#{name} tried to draw #{excess} more card#{'s' unless excess == 1}#{reason}, but their deck was empty.",
                            :css_class => "player#{seat} card_draw")
    end
    save!

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

  def resolve(params)
    # Checks, including retrieving the action.
    this_act, response = find_action(params[:pa_id])

    if this_act.nil?
      return response
    end

    # Now split the card, and make sure it makes sense.
    params[:card] =~ /([[:alpha:]]+::[[:alpha:]]+)([0-9]+)/
    card_type, card_id = $1, $2
    begin
      card = card_type.constantize.find(card_id)
    rescue
      return "Couldn't find a #{card_type} with id #{card_id}"
    end

    # Build the expected method name
    meth = "resolve"
    if params.include? :substep
      meth += "_#{params[:substep]}"
    end

    # Check that the card responds to the method
    if not card.respond_to? meth
      return "Card of type #{card_type} can't respond to #{meth}"
    end

    # Make sure the action we're resolving has the correct parameters
    act_text = "resolve_"
    act_text << params[:card]
    if params.include? :substep
      act_text << "_#{params[:substep]}"
    end
    r = Regexp.new("^" + act_text + "(;.*)?")

    match = r.match(this_act.expected_action)
    param_string = match[1]
    act_params = {}
    if param_string
      param_string.scan(/;([^;=]*)=([^;=]*)/) {|m| act_params[m[0].to_sym] = m[1]}
    end

    act_params.each do |key, value|
      if (!params.include? key) || (params[key] != value)
        this_act = nil
        break
      end
    end

    if this_act.nil?
      return "Couldn't find action to exactly match all required arguments"
    end

    # All good - remove the action and call through
    parent_act = this_act.parent
    Game.current_act_parent = parent_act
    params[:this_act_id] = this_act.id
    this_act.destroy

    return card.method(meth).untaint.call(self, params, parent_act)
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
    set = cards(true).in_location(location.to_s)
    set.each_with_index do |card, ix|
      card.position = ix

      # Leave a gap at the specified offset, allowing cards to "slot in" to
      # the deck
      card.position += 1 if hole_at && ix >= hole_at
      card.save
    end
  end

  def shuffle_discard_under_deck(options = {})
    options = {:log => true}.merge(options)
    # Take all the cards in the discard pile and put them, in random order,
    # at the end of the deck array.
    renum(:deck)
    cards(true).in_discard.shuffle.each do |card|
      cards.deck << card
      card.location = "deck"
      card.position = cards.deck.count
      card.save
    end

    if options[:log]
      game.histories.create!(:event => "#{name} shuffled their discard pile.",
                            :css_class => "player#{seat} shuffle")
    end
  end

  def calc_score
    self.score ||= vp_chips || 0
    self.score += self.cards(true).inject(0) {|sum, card| sum + card.points}
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

  def waiting_for?(action)
    pending_actions.active.pluck(:expected_action).any? { |exp| exp =~ Regexp.new("^" + action + "(;.*)?") }
  end

#  def queue(parent_act, act, opts={})
#    text = opts.delete :text
#    action = "player_#{act};player=#{id}"
#    action += ";" + opts.map {|k,v| "#{k}=#{v}"}.join(';') unless opts.empty?
#    parent_act.queue(:expected_action => action,
#                     :text => text,
#                     :game => game)
#  end

  # Queue up an action in order to gain a card. This needs to handle gaining both
  # from a pile, and of a specific card (as in Thief). opts must contain either
  # :pile => <Pile object> or :card => <Card object>
  def gain(parent_act, opts = {})
    raise "No :card or :pile to gain" unless (opts.include?(:card) || opts.include?(:pile))
    raise "Both :card and :pile given to gain" if (opts.include?(:card) && opts.include?(:pile))
    raise ":card supplied but not a Card" if (opts[:card] && !opts[:card].is_a?(Card))
    raise ":pile supplied but not a Pile" if (opts[:pile] && !opts[:pile].is_a?(Pile))

    # Trip any cards that need to trigger before the gain to change the details of the gain
    # (as for, say, Nomad Camp)
    card_types = game.cards.unscoped.select('distinct type').map(&:type).map(&:constantize)
    gain_params = {:gainer => self,
                   :card => opts[:card], # Can be nil
                   :pile => opts[:pile], # Can be nil
                   :parent_act => parent_act,
                   :location => opts[:location] || 'discard',
                   :position => opts[:position] || 0}
    card_types.each do |type|
      if type.respond_to?(:witness_pre_gain_modify)
        type.witness_pre_gain_modify(gain_params)
      end
    end
    opts[:location] = gain_params[:location]
    opts[:position] = gain_params[:position]

    action = "player_do_gain;player=#{id};"
    if opts[:pile]
      action << "pile_id=#{opts.delete(:pile).id}"
    else
      action << "card_id=#{opts.delete(:card).id}"
    end
    action << ";" + opts.map {|k,v| "#{k}=#{v}"}.join(';') unless opts.empty?
    parent_act = parent_act.children.create!(:expected_action => action,
                                             :game => game)

    # Trip any cards that need to trigger before the gain in order to queue up
    # another action before the gain happens (as for, say, Trader)
    gain_params[:parent_act] = parent_act
    card_types.each do |type|
      if type.respond_to?(:witness_pre_gain_queue)
        parent_act = type.witness_pre_gain_queue(gain_params)
      end
    end

    return parent_act
  end

  def emailed
    self.last_emailed = Time.now
    save!
  end

  # Synthetic attribute for number of actions
  def actions
    unless game.pending_actions.any? {|act| act.expected_action == "player_end_turn;player=#{id}"}
      return nil
    end
    pending_actions.where(:expected_action => 'play_action').count
  end

  def buys
    unless game.pending_actions.any? {|act| act.expected_action == "player_end_turn;player=#{id}"}
      return nil
    end
    pending_actions.where(:expected_action => 'buy').count
  end

private

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
