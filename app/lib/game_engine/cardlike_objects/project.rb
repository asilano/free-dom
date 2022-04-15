module GameEngine
  module CardlikeObjects
    class Project
      extend CardDecorators::BasicDecorators
      include CardModules::Purchasable

      delegate :readable_name, to: :class

      def self.types = ["project"]

      def self.randomiser? = true

      attr_reader :owners

      def initialize
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
    end
  end
end
