module GameEngine
  class Scheduler
    def initialize
      @triggers = []
    end

    def trigger(&block)
      @triggers << block
    end

    def work
      until @triggers.empty?
        @triggers.shift.call
      end
    end
  end
end
