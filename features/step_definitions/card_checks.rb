# Matches
#   there should be 10 Copper cards in piles
#   there should be 1 Estate card in hands
#   there should be 0 Copper cards not in hands, piles, decks
Then /there should be (\d+) (.*) cards?( not)? in (.*)/ do |num, kind, negate, locations|
  locs = locations.split(/,\s+/)
  locs.map!{|l| l.chomp('s')}
  result = @game.cards.where(["type = :type and location #{'not' if negate} in (:loc)", {:type => CARD_TYPES[kind].name, :loc => locs}]).count
  assert_equal num.to_i, result
end

# Matches
#   I should have played Copper
#   Bob should have played Copper, Silver
Then /(.*) should have played (.*)/ do |name, kinds|
  name = 'Alan' if name == 'I'
  
  kinds.split(/,\s*/).each do |kind|
    @hand_contents[name].delete_at(@hand_contents[name].index(kind))
    @play_contents[name] << kind
  end
end
  
# # Matches
# #   I should have Gold in play
# #   Bob should have Copper, Gold in play
# #
# # Note that this sets the exact expected contents; we can do this because "shuffling" is now sorting by unprefixed name
# Then /(.*) should have ((?!nothing).*) in (.*)/ do |name, kinds, location|
  # name = 'Alan' if name == 'I'
  # exp = instance_variable_get("@#{location}_contents")[name]
  
  # exp.replace(kinds.split(/,\s*/))
# end

Then /(.*) should have drawn (\d+) cards?/ do |name, num|
  name = 'Alan' if name == 'I'
  deck = @deck_contents[name]
  
  num.to_i.times do
    if deck.empty?
      # Deck is empty. "Shuffle" discards - which should get the same order as the main program
      deck.concat(@discard_contents[name].shuffle)
      @discard_contents[name] = []      
    end
    
    unless deck.empty?
      # Still cards in deck. Move the topmost into the hand.      
      @hand_contents[name] << deck.shift
    end    
  end
end
  
Then(/(.*) should have put ((?:(?:#{CARD_NAMES.join('|')})(?:, )?)*) (?:from (?:his|my) (.*) )?on top of (?:his|my) deck/) do |name, kinds, from_loc|
  name = "Alan" if name == "I"
  player = @players[name]
  
  deck = @deck_contents[name]
  
  kinds.split(/,\s*/).each do |kind|
    deck.unshift(kind)
    
    if from_loc
      from = instance_variable_get("@#{from_loc}_contents")[name]
      assert_contains from, kind
      from.delete_at(from.index(kind))
    end
  end
end

Then(/(.*) should have discarded ((?:(?:#{CARD_NAMES.join('|')})(?:, )?)*)/) do |name, kinds|
  name = "Alan" if name == "I"
  player = @players[name]
    
  kinds.split(/,\s*/).each do |kind|
    @discard_contents[name].unshift(kind)
    assert_contains @hand_contents[name], kind
    @hand_contents[name].delete_at(@hand_contents[name].index(kind))
  end
end

Then(/(.*) should have gained (.*)/) do |name, kinds|
  name = "Alan" if name == "I"
  @discard_contents[name] += kinds.split(/,\s*/)
end