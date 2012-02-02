Then /there should be (\d+) (.*) cards?( not)? in (.*)/ do |num, kind, negate, locations|
  locs = locations.split(/,\s+/)
  locs.map!{|l| l.chomp('s')}
  result = @game.cards.where(["type = :type and location #{'not' if negate} in (:loc)", {:type => CARD_TYPES[kind].name, :loc => locs}]).count
  assert_equal num.to_i, result
end

Then /I should( not)? have( only)? (.*) in (.*)/ do |negate, only, kinds, location|
  actual = @me.cards.where(:location => location).map(&:readable_name)
  if !negate && !only
    assert_subset kinds.split(/,\s*/), actual
  elsif !negate && only
    assert_same_elements kinds.split(/,\s*/), actual
  else
    assert_disjoint kinds.split(/,\s*/), actual
  end
end

Then /I should have drawn (\d+) cards?/ do |num|
  deck = [] + (@deck_contents[:fixed_top] || []) + (@deck_contents[@name_rand_top] || [])
  deck.concat((@deck_contents[:fixed_mid] || []) + (@deck_contents[@name_rand_mid] || []))
  deck.concat((@deck_contents[:fixed_bottom] || []) + (@deck_contents[@name_rand_bottom] || []))
  
  hand = @hand_contents.values.flatten
  
  drawn = deck.shift(num.to_i)
  hand.concat drawn
  
  if (drawn.length == num.to_i)
    assert_same_elements @me.cards.hand.map(&:readable_name), hand
    assert_same_elements @me.cards.deck.map(&:readable_name), deck
  else
    actual_hand = @me.cards.hand.map(&:readable_name)
    
    Rails.logger.info("actual_hand before subset: #{actual_hand.inspect}")
    assert_subset hand, actual_hand
    Rails.logger.info("actual_hand after subset: #{actual_hand.inspect}")
    
    hand.each {|c| actual_hand.delete_at(actual_hand.index(c))}
    assert_equal actual_hand.length, num.to_i - drawn.length
    assert_subset actual_hand, @discard_contents.values.flatten
  end
end
  