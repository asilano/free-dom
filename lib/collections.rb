module Collections
  class CardsCollection < Array
    %w<deck hand enduring pile>.each do |loc|
      define_method(loc) do
        select { |c| c.location == loc }
      end
    end
    %w<play discard trash>.each do |loc|
      define_method("in_#{loc}") do
        select { |c| c.location == loc }
      end
    end
    %i<revealed peeked>.each do |qual|
      define_method(qual) do
        select { |c| c.send(qual) }
      end
    end

    def of_type(*types)
      select { |c| types.include? c.type }
    end

    def in_location(*locs)
      select { |c| locs.include? c.location }
    end
  end
end