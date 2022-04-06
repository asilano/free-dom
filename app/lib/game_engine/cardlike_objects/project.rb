module GameEngine
  module CardlikeObjects
    class Project
      delegate :readable_name, to: :class

    end
  end
end
