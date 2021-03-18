module GameEngine
  class PlayerState
    include PlayerModules::Inspection
    include PlayerModules::Manipulation

    attr_reader :user, :cards, :game_state, :game
    attr_accessor :seat, :actions, :buys, :cash, :score

    delegate :name, to: :user

    def initialize(user, game_state)
      @user = user
      @game_state = game_state
      @game = game_state.game
      @cards = []
      @score = 0
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
      list.sort_by! do |exemplar|
        [-(exemplar[:score] || -Float::INFINITY),
         -(exemplar[:cash] || -Float::INFINITY),
         exemplar[:name]]
        # next 0 unless a[:score] || b[:score]
        # next 1 if a[:score].nil?
        # next -1 if b[:score].nil?
        # b[:score] <=> a[:score]
      end
      list.last[:last] = true
      list
    end
  end
end
