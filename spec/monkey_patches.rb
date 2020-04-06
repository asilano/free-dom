module MonkeyPatches
  module Array
    module Shuffling
      def shuffle(*args)
        sort
      end
      def shuffle!(*args)
        sort!
      end
    end
  end

  module GameEngine
    module Card
      module Sorting
        def <=>(other)
          readable_name <=> other.readable_name
        end
      end
    end

    module PlayerState
      module Sorting
        def <=>(other)
          name <=> other.name
        end
      end
    end
  end
end
