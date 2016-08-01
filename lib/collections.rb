module Collections
  class CardsCollection < Array
    %w<deck hand enduring pile>.each do |loc|
      define_method(loc) do
        CardsCollection.new(select { |c| c.location == loc })
      end
    end
    %w<play discard trash>.each do |loc|
      define_method("in_#{loc}") do
        CardsCollection.new(select { |c| c.location == loc })
      end
    end
    %i<revealed peeked>.each do |qual|
      define_method(qual) do
        CardsCollection.new(select { |c| c.send(qual) })
      end
    end

    def of_type(*types)
      CardsCollection.new(select { |c| types.include? c.class.to_s })
    end

    def in_location(*locs)
      CardsCollection.new(select { |c| locs.include? c.location })
    end

    def in_pile(pile)
      CardsCollection.new(select { |c| c.pile == pile })
    end

    def belonging_to_player(player)
      CardsCollection.new(select { |c| c.player && c.player.id == player.id })
    end

    def not
      Negation.new(self)
    end

    def +(arr)
      CardsCollection.new(select{|_|true} + arr)
    end
  end

  class Negation
    def initialize(obj)
      @obj = obj
    end

    def method_missing(name, *args, &block)
      positive = @obj.send(name, *args, &block)
      @obj - positive
    end
  end
end