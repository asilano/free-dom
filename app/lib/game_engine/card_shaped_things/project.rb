module GameEngine
  module CardShapedThings
    class Project
      extend CardDecorators::BasicDecorators
      include CardModules::Purchasable

      delegate :types, :readable_name, to: :class

      def self.types = ["project"]

      def self.randomiser? = true

      attr_reader :game_state, :owners

      def initialize(game_state)
        @game_state = game_state
        @owners = []
      end

      def player_can_buy?(player:)
        super && !owners.include?(player)
      end

      def be_bought_by(player)
        owners << player
      end

      def cost
        self.class.raw_cost
      end

      def text_for(player)
        player.name
      end
    end
  end
end
