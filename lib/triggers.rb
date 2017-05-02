module Triggers
private

  class Trigger
    def initialize(game)
      @game = game
      @observers = []
    end

    def observe(obj, method)
      Rails.logger.info("Observing #{obj.inspect}")
      ignore(obj, method)
      @observers << Watcher.new(obj, method)
      Rails.logger.info("Observers: #{@observers}")
    end

    def ignore(obj, method)
      @observers.delete_if { |w| w.object == obj && w.method == method }
    end

    def trigger(state)
      parent_strand = @game.current_strand
      occur = Occurrence.new

      while @observers.any? { |w| w.occur_strands[occur].nil? } do
        @observers.each do |watcher|
          @game.current_strand = @game.add_strand(parent_strand)
          watcher.occur_strands[occur] = @game.current_strand
          watcher.object.send(watcher.method, state)
        end
      end

      @game.current_strand = parent_strand
    end
  end

public
  class OnAttack < Trigger
  end

  class Watcher
    attr_accessor :occur_strands
    attr_reader :object, :method

    def initialize(obj, meth)
      @object = obj
      @method = meth
      @occur_strands = {}
    end
  end

  class Occurrence
  end
end
