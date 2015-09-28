# Override shuffle algorithms to a "somewhat random" sort. Allows us to know we have the same arrangement after shuffle
class Array
  include Test::Unit::Assertions

  def shuffle
    sort
  end

  def shuffle!
    sort!
  end

  def delete_first(item, opts = {})
    allow_fail = opts[:allow_fail]

    assert_contains(self, item) unless allow_fail
    delete_at(index(item))
  end
end

class Card < ActiveRecord::Base
  def <=>(rhs)
    return readable_name <=> rhs.readable_name
  end

  def self.non_card
    "Ace of Spades"
  end
end