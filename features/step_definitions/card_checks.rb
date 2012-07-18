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
Then(/(.*) should have played #{CardList}/) do |name, kinds|
  name = 'Alan' if name == 'I'
  
  kinds.split(/,\s*/).each do |kind|
    /(.*) ?x ?(\d+)/ =~ kind
    kind = $1.rstrip if $1
    num = $2.andand.to_i || 1
    
    num.times do
      @hand_contents[name].delete_first(kind)
      if CARD_TYPES[kind].is_duration?
        @enduring_contents[name] << kind
      else
        @play_contents[name] << kind
      end
    end
  end
end
  
# Matches
#   I should have Gold in play
#   Bob should have Copper, Gold in play
#
# Note that this sets the exact expected contents; we can do this because "shuffling" is now sorting by unprefixed name
Then /(.*) should have #{CardList} [io]n (?:my )?(.*)/ do |name, kinds, location|
  name = 'Alan' if name == 'I'
  exp = instance_variable_get("@#{location}_contents")[name]

  exp.replace(kinds.split(/,\s*/))
end

# Matches
#  I should have drawn 1 card
#  Bob should have drawn 3 cards
Then /(.*) should have drawn (\d+|a) cards?/ do |name, num|
  name = 'Alan' if name == 'I'
  num = 1 if num == 'a'
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

# Matches
#  I should have shuffled my discards
Then /(.*) should have shuffled (?:his|my) discards/ do |name|
  name = 'Alan' if name == 'I'
  @deck_contents[name].concat(@discard_contents[name].shuffle)
  @discard_contents[name] = []
end

# Matches
#   I should have put Silver on top of my deck // (that is, from an untracked location)
#   Bob should have put Estate, Copper from his hand on top of his deck // (that is, Copper is on top and Estate is underneath)
Then(/(.*) should have put #{CardList} (?:from (?:his|my) (.*) )?on top of (?:his|my) deck/) do |name, kinds, from_loc|
  name = "Alan" if name == "I"
  player = @players[name]
  
  deck = @deck_contents[name]
  
  kinds.split(/,\s*/).each do |kind|
    /(.*) ?x ?(\d+)/ =~ kind
    kind = $1.rstrip if $1
    num = $2.andand.to_i || 1
    
    num.times do
      deck.unshift(kind)
      
      if from_loc
        from = instance_variable_get("@#{from_loc}_contents")[name]
        assert_contains from, kind
        from.delete_first(kind)
      end
    end
  end
end

# Matches
#   I should have discarded Copper, Curse
#   Bob should have discarded Copper
Then(/(.*) should have discarded #{CardList}$/) do |name, kinds|
  name = "Alan" if name == "I"
  player = @players[name]
    
  kinds.split(/,\s*/).each do |kind|
    /(.*) ?x ?(\d+)/ =~ kind
    kind = $1.rstrip if $1
    num = $2.andand.to_i || 1
    
    num.times do
      @discard_contents[name].unshift(kind)
      assert_contains @hand_contents[name], kind
      @hand_contents[name].delete_first(kind)
    end
  end
end

# Matches
#   I should have discarded the cards named "rest of hand"
Then(/(.*) should have discarded the cards named "([^"]*)"/) do |name, grp_name|
  name = "Alan" if name == "I"
  player = @players[name]
  
  cards = @named_cards[grp_name]
  assert_not_nil cards
    
  cards.each do |kind|
    @discard_contents[name].unshift(kind)
    assert_contains @hand_contents[name], kind
    @hand_contents[name].delete_first(kind)
  end
end

# This step is not usually required; its only current use is in Adventurer, where
# there's a Scenario Outline, and "nothing" is an argument.
# Matches
#   I should have discarded nothing
Then /^(.*) should have discarded nothing$/ do |_|
end

# Matches
#   I should have gained Copper
#   Bob should have gained Curse, Curse
Then(/^(.*) should have gained #{CardList}$/) do |name, kinds|
  name = "Alan" if name == "I"
  kinds.split(/,\s*/).each do |kind|
    /(.*) ?x ?(\d+)/ =~ kind
    kind = $1.rstrip if $1
    num = $2.andand.to_i || 1
    
    num.times do
      @discard_contents[name] << kind
    end
  end
end

# Matches
#   I should have moved Copper, Silver x2, Gold from discard to hand
Then(/(.*) should have moved #{CardList} from (.*) to (.*)/) do |name, kinds, from, to|
  name = "Alan" if name == "I"
  player = @players[name]
  
  kinds.split(/,\s*/).each do |kind|
    /(.*) ?x ?(\d+)/ =~ kind
    kind = $1.rstrip if $1
    num = $2.andand.to_i || 1
    
    num.times do  
      # First, remove the cards from whence they came
      if from == "deck"
        # The named cards should be on top in order     
        assert_equal kind, @deck_contents[name][0]
        
        @deck_contents[name].shift
      else
        from_cont = instance_variable_get("@#{from}_contents")[name]    
        from_cont.delete_first(kind)
      end
      
      # Now, put them onto the target
      to_cont = instance_variable_get("@#{to}_contents")[name]
      to_cont.unshift kind
    end
  end
end

# Matches
#   I should have moved the cards named "named cards" from deck to discard
Then(/(.*) should have moved the cards named "([^"]*)" from (.*) to (.*)/) do |name, grp_name, from, to|
  name = "Alan" if name == "I"
  player = @players[name]
  
  cards = @named_cards[grp_name]
  assert_not_nil cards
  
  # First, remove the cards from whence they came
  if from == "deck"
    # The named cards should be on top in order
    assert_operator @deck_contents[name].length, :>=, cards.length
    assert_equal cards, @deck_contents[name][0, cards.length]
    
    @deck_contents[name].shift(cards.length)
  else
    from_cont = instance_variable_get("@#{from}_contents")[name]    
    cards.each {|card| from_cont.delete_first(card)}
  end
  
  # Now, put them onto the target
  to_cont = instance_variable_get("@#{to}_contents")[name]
  cards.each {|card| to_cont.unshift card}
end

# Matches
#   I should have moved cards 1,3,4 from deck to discard
# Note: 0-indexed.
Then /(.*) should have moved cards? ((?:\d+,? ?)*) from deck to (.*)/ do |name, list, to|
  name = "Alan" if name == "I"
  player = @players[name]
  
  indices = list.split(/,\s*/).map(&:to_i)

  # First, remove the cards from the deck
  assert_operator @deck_contents[name].length, :>, indices.max
  cards = []
  indices.each do |ix| 
    cards << @deck_contents[name][ix] 
    @deck_contents[name][ix]= nil
  end
  @deck_contents[name].compact!
    
  # Now, put them onto the target
  to_cont = instance_variable_get("@#{to}_contents")[name]
  cards.each {|card| to_cont.unshift card}
end 

# Used to note that a card has moved from a tracked zone to anywhere else
#
# Matches
#   I should have removed Curse from my hand
#   Bob should have removed Copper, Curse from his discard
Then(/(.*) should have removed #{CardList} from (?:his |my )?(.*)/) do |name, kinds, location|
  name = "Alan" if name == "I"
  player = @players[name]
  
  from = instance_variable_get("@#{location}_contents")[name]
  kinds.split(/,\s*/).each do |kind| 
    /(.*) ?x ?(\d+)/ =~ kind
    kind = $1.rstrip if $1
    num = $2.andand.to_i || 1
    
    num.times do
      from.delete_first(kind)
    end
  end
end

# Used to note that a card has moved to a tracked zone from anywhere else
#
# Matches
#   I should have placed Curse into my hand
#   Bob should have gained Copper, Curse to his discard
Then(/(.*) should have (?:placed|gained) #{CardList} (?:in|to|into) (?:his |my )?(.*)/) do |name, kinds, location|
  name = "Alan" if name == "I"
  player = @players[name]
  
  to = instance_variable_get("@#{location}_contents")[name]
  kinds.split(/,\s*/).each do |kind| 
    /(.*) ?x ?(\d+)/ =~ kind
    kind = $1.rstrip if $1
    num = $2.andand.to_i || 1
    
    num.times do
      to << kind
    end
  end
end

# One-off check that a player has got the correct cards revealed.
# Note that you must list all the revealed cards!
#
# Matches
#   I should be revealing Copper, Duchy
#   Bob should be revealing nothing
Then(/(.*) should be revealing (#{CardListNoCapture}|nothing)/) do |name, kinds|
  name = "Alan" if name == "I"
  player = @players[name]

  if kinds == "nothing"
    assert_empty player.cards.revealed(true)
  else
    expected = []
    kinds.split(/,\s*/).each do |kind|
      /(.*) ?x ?(\d+)/ =~ kind
      kind = $1.rstrip if $1
      num = $2.andand.to_i || 1

      num.times {expected << kind}
    end
    assert_equal expected, player.cards.revealed(true).map(&:readable_name)
  end
end

# Check that a player is peeking at the correct cards
#
# Matches
#   I should have seen Province
#   Bob should have seen Copper, Copper, Estate
Then /^(.*) should have seen (#{CardListNoCapture}|nothing)/ do |name, kinds|
  name = "Alan" if name == "I"
  player = @players[name]
  
  if kinds == "nothing"
    assert_empty player.cards.peeked(true)
  else
    expected = []
    kinds.split(/,\s*/).each do |kind|
      /(.*) ?x ?(\d+)/ =~ kind
      kind = $1.rstrip if $1
      num = $2.andand.to_i || 1

      num.times {expected << kind}
    end
    assert_equal expected, player.cards.peeked(true).map(&:readable_name)
  end
end
