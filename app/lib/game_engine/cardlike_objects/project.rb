module GameEngine
  module CardlikeObjects
    class Project
      extend CardDecorators::BasicDecorators

      delegate :readable_name, to: :class

      def self.types = ["project"]

      def self.randomiser? = true

      def cost
        self.class.raw_cost
      end
    end
  end
end
