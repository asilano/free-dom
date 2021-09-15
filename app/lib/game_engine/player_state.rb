module GameEngine
  class PlayerState
    include PlayerModules::Inspection
    include PlayerModules::Manipulation

    attr_reader :user, :cards, :game_state, :game
    attr_accessor :seat, :actions, :buys, :cash, :score, :coffers, :villagers

    delegate :name, to: :user

    def initialize(user, game_state)
      @user = user
      @game_state = game_state
      @game = game_state.game
      @cards = []
      @score = 0

      @coffers = 0
      @villagers = 0
    end

    # Processors
    def calculate_score
      @score += cards.select(&:victory?).map(&:points).sum
    end

    def decklist
      list = cards.group_by(&:class).map do |klass, cs|
        exemplar = cs.first
        entry = {
          types: exemplar.class.types,
          count: cs.count,
          name:  klass.readable_name,
          text:  exemplar.try(:text),
          last:  false
        }
        entry[:score] = exemplar.points if exemplar.respond_to?(:points)
        entry[:cash] = exemplar.cash if exemplar.respond_to?(:cash)
        entry
      end

      # Sort so that:
      # * Anything with a point value is first, highest to lowest
      # * Next, anything with a cash value, highest to lowest
      # * Lastly, everything else alphabetically
      list.sort_by! do |exemplar|
        [-(exemplar[:score] || -Float::INFINITY),
         -(exemplar[:cash] || -Float::INFINITY),
         exemplar[:name]]
      end
      list.last[:last] = true
      list
    end

    def inspect
      "PlayerState:#{name}"
    end
  end
end
