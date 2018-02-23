class Card
  include ActiveModel::Model
  extend Passthrough
  extend CardDecorators
  include GamesHelper
  include Resolvable

  # Attributes that used to be in the database
  attr_accessor :game, :id, :player, :pile, :location, :position, :revealed, :peeked, :state
  attr_accessor :can_react_to

  def initialize(*args, &block)
    super
    @can_react_to = []
    @id = game.andand.next_card_id
  end

  def to_s
    readable_name
  end

  def self.readable_name
    to_s.readable_name
  end

  def self.readable_name_with_cost
    readable_name + " (cost: #{cost})"
  end

  def modifiers
    []
  end

  def self.expansions
    [BaseGame, Intrigue, Seaside, Prosperity, Hinterlands, PromoCards]
  end

  # The ever-present Victory cards
  @@basic_victory_types = %w<Estate Duchy Province Curse>.map {|t| ("BasicCards::" + t)}

  # The ever-present Treasure cards
  @@basic_treasure_types = %w<Copper Silver Gold>.map {|t| ("BasicCards::" + t)}

  def self.basic_victory_types
    @@basic_victory_types.map(&:constantize)
  end

  def self.basic_treasure_types
    @@basic_treasure_types.map(&:constantize)
  end

  def self.all_card_types
    expansions.inject([]) { |mem, var| mem + var.card_classes } +
      self.basic_victory_types + self.basic_treasure_types
  end

  def self.all_kingdom_cards
    expansions.inject([]) { |mem, var| mem + var.kingdom_cards }
  end

  NonCards = [ "Ace of Spades",
               "Mr Bun the Baker",
               "Joker",
               "The Hanged Man",
               "3 of Cups",
               "Serra Angel",
               "Absolutely Nothing",
               "Birthday",
               "Great A'Tuin",
               "Pikachu",
               "PCIe",
               "Credit"
               ]
  def self.non_card
    NonCards[rand(NonCards.length)]
  end

  def self.starting_size(num_players)
    # Unless overridden, start with 10 cards
    10
  end

  # Card class accessors. Subclasses will override only those which are true
  # Define them to passthrough, so Card.new.is_victory? calls Card.is_victory?
  passthrough :is_victory?, :is_treasure?, :is_action?, :is_attack?,
              :is_reaction?, :is_duration?, :is_curse?, :varieties, :cash, :text,
              :readable_name, :is_special?
  def self.is_victory?
    false
  end
  def self.is_treasure?
    false
  end
  def self.is_special?
    false
  end
  def self.is_action?
    false
  end
  def self.is_attack?
    false
  end
  def self.is_reaction?
    false
  end
  def self.is_duration?
    false
  end
  def self.is_curse?
    false
  end

  def self.varieties
    ["victory", "treasure", "action", "attack", "reaction", "duration", "curse"].select do |v|
      self.method(("is_" + v + "?").to_sym).untaint.call
    end
  end

  def self.cash
    0
  end
  def points
    0
  end
  def self.text
    ""
  end
  def self.cost
    self.raw_cost
  end

  def cost
    res = self.class.cost

    # Handle Bridges
    bridges = game.facts.include?(:bridges) ? game.facts[:bridges] : 0
    res = [0, res - bridges].max

    # Handle Highways
    if game.current_turn_player
      highways = game.current_turn_player.cards.in_play.of_type("Hinterlands::Highway").length
      res = [0, res - highways].max
    end

    # Handle Quarries
    if is_action? && game.current_turn_player
      quarries = game.current_turn_player.cards.in_play.of_type("Prosperity::Quarry").length
      res = [0, res - 2*quarries].max
    end

    return res
  end

  # Default function to buy a card. Can be overridden by card-types which are
  # infinite in size.
  def gain(actor, journal, locn: 'discard', posn: -1)
    if pile.andand.state.andand[:trade_route_token]
      # Card's pile currently has a Trade Route token on it. Remove that token
      # and increment the game's Trade Route value
      pile.state[:trade_route_token] = false
      game.facts[:trade_route_value] ||= 0
      game.facts[:trade_route_value] += 1
    end

    actor.renum(locn, posn)
    self.pile.cards.delete(self)
    self.pile = nil
    self.location = locn
    self.player = actor
    self.position = posn
    actor.cards << self

    if !game.cards.of_type("Seaside::Smuggler").empty?
      # Game has the Smugglers card in it, so we need to track the
      # card types gained
      actor.state.gained_last_turn << self.class.to_s
    end

    # TODO: publish post-gain event

  end

  # We expect to override play for every action; but having it here allows us
  # to raise if the card isn't an action, and to move it
  # to play (or to enduring for durations).
  #
  # A note on the override functions; if input is needed from the player, the
  # function should likely add a "resolve_<card-name><card-ID>[_<substep>]" action to the
  # player. Player can then pass responsibility for the controls through to the
  # card by regexp.
  def play
    raise "Card not an action" unless is_action?
    game.facts[:actions_played] ||= 0
    game.facts[:actions_played] += 1

    # Only move the card if it's currently in-hand.
    if @location == "hand"
      if is_duration?
        @location = "enduring"
      else
        @location = "play"
      end
    end
  end

  # Base-class function for a Duration coming off-duration at the start of the
  # Player's turn. This function just moves the Duration to In Play; the subclass
  # may override this function to do other Stuff.
  def end_duration(parent_act)
    # Only durations and action-multipliers should be durating.
    raise "Card not a duration" unless (is_duration? || self.class == BaseGame::ThroneRoom || self.class == Prosperity::KingsCourt)
    raise "Card not enduring" unless location == "enduring"

    self.location = "play"
    save!
    return "OK"
  end

  # The card is leaving play - a card may override this if it has work to do then
  # (For example Seaside::Treasury)
  def discard_from_play(parent_act = nil)
    raise "Card not in play" unless location == 'play'

    discard
  end

  # This moves a treasure card to play, and adds its reported cash to the owning player, unless
  # call_through is true (meaning a subclass has invoked super). The cash added is returned.
  def play_treasure(call_through: false)
    raise "Card not a treasure" unless is_treasure?
    self.location = "play"

    if !call_through
      player.cash += cash
      cash
    else
      nil
    end
  end

  # Trash a card - move it from its current location to game.cards.in_trash
  # and nil off its player.
  # If the card is already in trash, still blank the player, but return
  # false to indicate "couldn't trash the card".
  def trash
    self.player = nil
    self.pile = nil
    self.revealed = false
    self.peeked = false

    if location != "trash"
      game.cards.in_trash << self
      self.location = "trash"
      self.position = game.cards.in_trash.size - 1

      return true
    else
      return false
    end
  end

  # Discard a card - move it from its current location to player.cards.in_discard
  # Raise if the card doesn't have a player
  def discard
    raise "Card not owned" unless player
    self.location = 'discard'
    self.position = -1
    self.revealed = false
  end

  # Peek at a card - mark it as peeked, so its owner can see it.
  # Raise if the card doesn't have a player
  def peek
    raise "Card not owned" unless player
    self.peeked = true
    save!
  end

  # Reveal a card - mark it as revealed, so everyone can see it.
  def reveal
    self.revealed = true
    save!
  end

  # Apply a moat effect to an attack for the given player
  def moat_attack(attack_action, ply)
    if attack_action.expected_action =~ /_doattack;/
      if attack_action.expected_action !~ /moated=true/
        attack_action.expected_action += ";moated=true"
        attack_action.save!
      end
    else
      if !attack_action.state.andand[ply.id].andand[:moated]
        attack_action.state_will_change!
        attack_action.state ||= {}
        attack_action.state[ply.id] ||= {}
        attack_action.state[ply.id][:moated] = true
        attack_action.save!
      end
    end
  end

  # Default no-op for acting at start of turn
  def witness_turn_start(_)
  end

private

  def clear_visibility
    if changed.include?('location') || changed.include?('player')
      self.revealed = false unless changed.include? 'revealed'
      self.peeked = false unless changed.include? 'peeked'
    end
    nil
  end
end
