AfterStep do |scenario|
  # Verify that each player's cards match what we expect
  @skip_card_checking ||= 0
  
  if @skip_card_checking == 0
    @players.each do |name, player|      
      assert_same_elements @hand_contents[name], player.cards.hand(true).map(&:readable_name)
      assert_same_elements @discard_contents[name], player.cards.in_discard(true).map(&:readable_name)
      assert_same_elements @play_contents[name], player.cards.in_play(true).map(&:readable_name)
      assert_same_elements @enduring_contents[name], player.cards.enduring(true).map(&:readable_name)
      
      assert_equal @deck_contents[name], player.cards.deck(true).map(&:readable_name)
    end
  else
    @skip_card_checking -= 1
  end
end

# Asserts that the given collection contains item x.  If x is a regular expression, ensure that
# at least one element from the collection matches x.  +extra_msg+ is appended to the error message if the assertion fails.
#
#   assert_contains(['a', '1'], /\d/) => passes
#   assert_contains(['a', '1'], 'a') => passes
#   assert_contains(['a', '1'], /not there/) => fails
def assert_contains(collection, x, extra_msg = "")
  collection = [collection] unless collection.is_a?(Array)
  msg = "#{x.inspect} not found in #{collection.to_a.inspect} #{extra_msg}"
  case x
  when Regexp
    assert(collection.detect { |e| e =~ x }, msg)
  else
    assert(collection.include?(x), msg)
  end
end

# Asserts that two arrays contain the same elements, the same number of times.  Essentially ==, but unordered.
#
#   assert_same_elements([:a, :b, :c], [:c, :a, :b]) => passes
def assert_same_elements(a1, a2, msg = nil)
  [:select, :inject, :size].each do |m|
    [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
  end

  assert a1h = a1.inject({}) { |h,e| h[e] = a1.select { |i| i == e }.size; h }
  assert a2h = a2.inject({}) { |h,e| h[e] = a2.select { |i| i == e }.size; h }

  assert_equal(a1h, a2h, msg)
end

def assert_subset(subset, superset, extra_msg = "")
  sub = subset.to_a.dup
  supe = superset.to_a.dup
  msg = "#{sub.inspect} is not a subset of #{supe.inspect} #{extra_msg}"
  failed = false
  sub.each do |elem|
    if supe.index(elem)
      supe.delete_at(supe.index(elem))
    else
      failed = true
      break
    end
  end
  
  assert(!failed, msg)
end

def assert_disjoint(left, right, extra_msg = "")
  left_a = left.to_a.dup
  right_a = right.to_a.dup
  msg = "#{left_a.inspect} and #{right_a.inspect} are not disjoint #{extra_msg}"
  failed = false
  left_a.each do |elem|
    if right_a.index(elem)
      failed = true
      break
    end
  end
  
  assert(!failed, msg)
end