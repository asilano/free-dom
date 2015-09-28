AfterStep do |scenario|
  # Make sure we have a correct record of each player's attribs
  @test_players.values.each(&:reload)

  # Verify that each player's cards match what we expect
  @skip_card_checking ||= 0

  if @skip_card_checking == 0
    @test_players.each do |name, player|
      player.renum(:deck)
      assert_same_elements @hand_contents[name], player.cards(true).hand.map(&:readable_name), "#{name}'s hand didn't match"
      assert_same_elements @discard_contents[name], player.cards(true).in_discard.map(&:readable_name), "#{name}'s discard didn't match"
      assert_same_elements @play_contents[name], player.cards(true).in_play.map(&:readable_name), "#{name}'s cards in play didn't match"
      assert_same_elements @enduring_contents[name], player.cards(true).enduring.map(&:readable_name), "#{name}'s enduring cards didn't match"

      assert_equal @deck_contents[name], player.cards(true).deck.map(&:readable_name), "#{name}'s deck didn't match"
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

# Asserts that the given collection does not contain item x.  If x is a regular expression, ensure that
# no element from the collection matches x.  +extra_msg+ is appended to the error message if the assertion fails.
#
#   assert_not_contains(['a', '1'], /\d/) => fails
#   assert_not_contains(['a', '1'], 'a') => fails
#   assert_not_contains(['a', '1'], /not there/) => passes
def assert_not_contains(collection, x, extra_msg = "")
  collection = [collection] unless collection.is_a?(Array)
  msg = "#{x.inspect} found in #{collection.to_a.inspect} #{extra_msg}"
  case x
  when Regexp
    assert(collection.detect { |e| e !~ x }, msg)
  else
    assert(!collection.include?(x), msg)
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
      supe.delete_first(elem)
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