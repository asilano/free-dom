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

    def +(arr)
      CardsCollection.new(select{|_|true} + arr)
    end
  end
end