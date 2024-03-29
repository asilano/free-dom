module GameEngine
  class Card
    extend CardDecorators::CardDecorators
    include CardModules::Expansions
    include CardModules::Introspection
    include CardModules::Manipulation

    attr_reader :game_state, :facts, :visibility_effects, :location
    attr_accessor :location_card, :hosting, :player, :pile, :revealed, :peeked, :interacting_with, :played_this_turn

    delegate :game, :observe, :trigger, to: :game_state

    # By default, 10 cards in a pile
    pile_size 10

    def initialize(game_state, pile: nil, player: nil)
      @game_state = game_state
      @pile = pile
      @player = player
      @hosting = []
      @facts = {}
      @visibility_effects = []
    end
  end
end
