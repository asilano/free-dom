module GameEngine
  module CardlikeObjects
    class Project
      delegate :readable_name, to: :class

      def self.types = ["Project"]

      def self.randomiser? = true
    end
  end
end
