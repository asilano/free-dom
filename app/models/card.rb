class Card < ActiveRecord::Base
  extend Passthrough
  extend CardDecorators
  include GamesHelper

  belongs_to :player
  belongs_to :game
  belongs_to :pile

  validates :revealed, :peeked, :inclusion => [true, false]

  default_scope :order => "location, position"
  %w<deck hand enduring pile>.each do |loc|
    scope loc.to_sym, :conditions => {:location => loc}
  end
  %w<play discard trash>.each do |loc|
    scope "in_#{loc}".to_sym, :conditions => {:location => loc}
  end
  scope :revealed, :conditions => {:revealed => true}
  scope :peeked, :conditions => {:peeked => true}
  scope :of_type, lambda {|*types| {:conditions => {:type => types}}}
  scope :in_location, lambda {|*locs| {:conditions => {:location => locs}}}

  before_save :clear_visibility, :check_end

  def to_s
    readable_name
  end

  def self.readable_name
    to_s.readable_name
  end

  def self.readable_name_with_cost
    readable_name + " (cost: #{cost})"
  end

  # Valid locations for a card to be in (and hence valid values for .location)
  # @@locations = %w<deck hand play discard pile trash>

  # The ever-present Victory cards
  @@basic_victory_types = %w<Estate Duchy Province Curse>.map {|t| ("BasicCards::" + t)}

  # The ever-present Treasure cards
  @@basic_treasure_types = %w<Copper Silver Gold>.map {|t| ("BasicCards::" + t)}

  # Valid card types from the base set (and hence valid values for [:type], and
  # valid sub-class names)
  def self.base_card_types
    BaseGame.card_classes.sort_by {|c| c.cost}
  end

  # Valid card types from the Intrigue set (and hence valid values for [:type], and
  # valid sub-class names)
  def self.intrigue_card_types
    Intrigue.card_classes.sort_by {|c| c.cost}
  end

  # Valid card types from the Seaside set (and hence valid values for [:type], and
  # valid sub-class names)
  def self.seaside_card_types
    Seaside.card_classes.sort_by {|c| c.cost}
  end

  # Valid card types from the Prosperity set (and hence valid values for [:type], and
  # valid sub-class names)
  def self.prosperity_card_types
    Prosperity.card_classes.sort_by {|c| c.cost}
  end

  # Valid card types from the Hinterlands set (and hence valid values for [:type], and
  # valid sub-class names)
  def self.hinterlands_card_types
    Hinterlands.card_classes.sort_by {|c| c.cost}
  end

  def self.basic_victory_types
    @@basic_victory_types.map {|t| t.constantize}
  end

  def self.basic_treasure_types
    @@basic_treasure_types.map {|t| t.constantize}
  end

  def self.all_card_types
    self.base_card_types + self.intrigue_card_types +
      self.seaside_card_types + self.prosperity_card_types +
      self.hinterlands_card_types +
      self.basic_victory_types + self.basic_treasure_types
  end

  # validates :type, :inclusion => Card.all_card_types

  def self.all_kingdom_cards
    BaseGame.kingdom_cards + Intrigue.kingdom_cards +
      Seaside.kingdom_cards + Prosperity.kingdom_cards +
      Hinterlands.kingdom_cards
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
    # A card may override this to ":unlimited"
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
    highways = game.current_turn_player.cards.in_play.of_type("Hinterlands::Highway").length
    res = [0, res - highways].max

    # Handle Quarries
    if is_action? && game.current_turn_player
      quarries = game.current_turn_player.cards.in_play.of_type("Prosperity::Quarry").length
      res = [0, res - 2*quarries].max
    end

    return res
  end

  # Default function to buy a card. Can be overridden by card-types which are
  # infinite in size.
  def gain(player, parent_act, new_location="discard", position=-1)
    if pile.andand.state.andand[:trade_route_token]
      # Card's pile currently has a Trade Route token on it. Remove that token
      # and increment the game's Trade Route value
      pile.state_will_change!
      game.facts_will_change!
      pile.state[:trade_route_token] = false
      game.facts[:trade_route_value] ||= 0
      game.facts[:trade_route_value] += 1
      pile.save!
      game.save!
    end

    player.renum(new_location, position)
    self.pile = nil
    self.location = new_location || "discard"
    self.player = player
    self.position = position || -1
    save!

    if !game.cards.of_type("Seaside::Smuggler").empty?
      # Game has the Smugglers card in it, so we need to track the
      # card types gained
      player.state.gained_last_turn_will_change!
      player.state.gained_last_turn << self.class.to_s
      player.state.save!
    end

    # Trip any cards that need to trigger after a card is gained
    card_types = game.cards.unscoped.select('distinct type').map(&:type).map(&:constantize)
    gain_params = {:gainer => player,
                   :card => self,
                   :parent_act => parent_act,
                   :location => new_location,
                   :position => position}
    card_types.each do |type|
      if type.respond_to?(:witness_post_gain)
        type.witness_post_gain(gain_params)
      end
    end

    return parent_act
  end

  # We expect to override play for every action; but having it here allows us
  # to raise if the card isn't an action, and to move it
  # to play (or to enduring for durations).
  #
  # A note on the override functions; if input is needed from the player, the
  # function should likely add a "resolve_<card-name><card-ID>[_<substep>]" action to the
  # player. Player can then pass responsibility for the controls through to the
  # card by regexp.
  def play(parent_act)
    raise "Card not an action" unless is_action?

    game.facts_will_change!
    game.facts[:actions_played] ||= 0
    game.facts[:actions_played] += 1
    game.save!

    # Only move the card if it's currently in-hand.
    if location == "hand"
      if is_duration?
        self.location = "enduring"
      else
        self.location = "play"
      end
    end

    save!
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

  # This just moves a treasure card to play. The caller should do the rest
  # (in practice, that will be Player adding the treasure's cash).
  def play_treasure(parent_act)
    raise "Card not a treasure" unless is_treasure?
    self.location = "play"
    save!

    return "OK"
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
      game.cards.in_trash(true) << self
      self.location = "trash"
      self.position = game.cards.in_trash.size - 1

      save!
      return true
    else
      save!
      return false
    end
  end

  # Discard a card - move it from its current location to player.cards.in_discard
  # Raise if the card doesn't have a player
  def discard
    raise "Card not owned" unless player
    player.cards.in_discard << self
    self.location = 'discard'
    self.position = -1
    save!
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

private

  def clear_visibility
    if changed.include?('location') || changed.include?('player')
      self.revealed = false unless changed.include? 'revealed'
      self.peeked = false unless changed.include? 'peeked'
    end
    nil
  end

  def check_end
    if location_changed? && location_was == 'pile'
      game.check_game_end
    end
    nil
  end
end
