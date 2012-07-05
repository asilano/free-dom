# Matches:
#   my hand is empty
#   Bob's hand is empty
Given(/^(\w*?)(?:'s)? hand is empty/) do |name|
  name = 'Alan' if name == 'my'
  @players[name].cards.hand.destroy_all
  @hand_contents[name] = []
end

# Matches:
#   my hand contains Smithy
#   my hand contains Smithy, Witch
#   Bob's hand contains Smithy, Witch and 4 other cards
#   my hand contains Smithy and 4 other cards named "rest of hand"
Given(/^(\w*?)(?:'s)? hand contains #{CardList}(?: and )?#{NamedRandCards}?/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'my'
  player = @players[name]
  player.cards.hand.destroy_all

  fixed_list ||= ""
  @hand_contents[name] = []
  fixed_list.split(/,\s*/).each do |kind|
    num = 1
    card_name = kind
    if /(.*) ?x ?(\d+)/ =~ kind
      card_name = $1.rstrip
      num = $2.to_i
    end
    
    num.times do
      @hand_contents[name] << card_name
      CARD_TYPES[card_name].create(:location => 'hand', :player => player, :game => player.game)
    end
  end
  
  @named_cards[rand_name] = [] if rand_name
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    # Watchtower in hand messes up any test that wants to gain a card;    
    redo if type == "Watchtower"
    redo if CARD_TYPES[type].is_treasure? && CARD_TYPES[type].is_special?
    @hand_contents[name] << type
    @named_cards[rand_name].andand << type
    CARD_TYPES[type].create(:location => 'hand', :player => player, :game => player.game)
  end
  
  player.renum(:hand)  
end

# Matches:
#   my deck is empty
#   Bob's deck is empty
Given(/^(\w*?)(?:'s)? deck is empty/) do |name|
  name = 'Alan' if name == 'my'
  @players[name].cards.deck.destroy_all
  @deck_contents[name] = []
end

# Matches "my deck contains <top> then <middle> then <bottom>". Either of the middle and bottom sections may be missing
# Each section may be like "Smithy, Witch" or like "4 other cards (named "rest of deck")"                                         
Given(/^(\w*?)(?:'s)?? deck contains (?:(#{NamedRandCardsNoMatch}|#{CardListNoCapture}) then )?(?:(#{NamedRandCardsNoMatch}|#{CardListNoCapture}) then )?(?:(#{NamedRandCardsNoMatch}|#{CardListNoCapture}))?/) do |name, top, middle, bottom|
  name = 'Alan' if name == 'my'
  player = @players[name]
  
  player.cards.deck.destroy_all
  @deck_contents[name] = []
  rand_top = rand_mid = fixed_bottom = false
  
  rand_top = (top =~ /(\d+) cards?(?: named "(.*)")?/)
  num_rand_top = $1
  name_rand_top = $2
  rand_mid = (middle =~ /(\d+) (?:other )?cards?(?: named "(.*)")?/)
  num_rand_mid = $1
  name_rand_mid = $2
  rand_bottom = (bottom =~ /(\d+) (?:other )?cards?(?: named "(.*)")?/)
  num_rand_bottom = $1
  name_rand_bottom = $2
  
  position = 0
    
  @named_cards[name_rand_top] = [] if name_rand_top
  if rand_top    
    num_rand_top.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[name] << type
      @named_cards[name_rand_top].andand << type
      CARD_TYPES[type].create(:location => 'deck', 
                              :player => player,
                              :position => position, 
                              :game => player.game)
      position += 1
    end
  elsif top
    top.split(/,\s*/).each do |type|
      num = 1
      card_name = type
      if /(.*) ?x ?(\d+)/ =~ type
        card_name = $1.rstrip
        num = $2.to_i
      end
      
      num.times do
        @deck_contents[name] << card_name
        CARD_TYPES[card_name].create(:location => 'deck', 
                                :player => player,
                                :position => position, 
                                :game => player.game)
        position += 1                             
      end
    end
  end
  
  @named_cards[name_rand_mid] = [] if name_rand_mid
  if rand_mid
    num_rand_mid.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[name] << type
      @named_cards[name_rand_mid].andand << type
      CARD_TYPES[type].create(:location => 'deck', 
                              :player => player,
                              :position => position, 
                              :game => player.game)
      position += 1
    end
  elsif middle
    middle.split(/,\s*/).each do |type|
      num = 1
      card_name = type
      if /(.*) ?x ?(\d+)/ =~ type
        card_name = $1.rstrip
        num = $2.to_i
      end
      
      num.times do
        @deck_contents[name] << card_name
        CARD_TYPES[card_name].create(:location => 'deck', 
                                :player => player,
                                :position => position, 
                                :game => player.game)
        position += 1                             
      end                            
    end
  end
  
  @named_cards[name_rand_bottom] = [] if name_rand_bottom
  if rand_bottom
    num_rand_bottom.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[name] << type
      @named_cards[name_rand_bottom].andand << type
      CARD_TYPES[type].create(:location => 'deck', 
                              :player => player,
                              :position => position, 
                              :game => player.game)
      position += 1
    end
  elsif bottom
    bottom_types = bottom.split(/,\s*/).each do |type|
      num = 1
      card_name = type
      if /(.*) ?x ?(\d+)/ =~ type
        card_name = $1.rstrip
        num = $2.to_i
      end
      
      num.times do
        @deck_contents[name] << card_name
        CARD_TYPES[card_name].create(:location => 'deck', 
                                :player => player,
                                :position => position, 
                                :game => player.game)
        position += 1                             
      end
    end
  end
  
  player.renum(:deck)
end
  
# Matches:
#   I have nothing in play
#   Bob has nothing in play
Given /^(\w*) ha(?:ve|s) nothing in play/ do |name|
  name = 'Alan' if name == 'I'
  @players[name].cards.in_play.destroy_all
  @play_contents[name] = []
end

# Matches:
#   I have Smithy in play
#   I have Smithy, Witch in play
#   Bob has Smithy, Witch and 4 other cards in play
#   I have Smithy and 4 other cards named "rest of play" in play
Given(/^(\w*) ha(?:ve|s) #{CardList}(?: and )?#{NamedRandCards}? in play/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'I'
  player = @players[name]
  player.cards.in_play.destroy_all

  fixed_list ||= ""
  fixed_list.split(/,\s*/).each do |kind|
    num = 1
    card_name = kind
    if /(.*) ?x ?(\d+)/ =~ kind
      card_name = $1.rstrip
      num = $2.to_i
    end
    
    num.times do
      @play_contents[name] << card_name
      CARD_TYPES[card_name].create(:location => 'play', :player => player, :game => player.game)
    end
  end
  
  @named_cards[rand_name] = [] if rand_name
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    redo if %w<Royal\ Seal Talisman>.include?(type) # Royal Seal and Talisman in play mess up gaining cards
    @play_contents[name] << type
    @named_cards[rand_name].andand << type
    CARD_TYPES[type].create(:location => 'play', :player => player, :game => player.game)
  end
  
  player.renum(:play)
end

# Matches:
#   I have nothing in discard
#   Bob has nothing in discard
Given /^(\w*) ha(?:ve|s) nothing in discard/ do |name|
  name = "Alan" if name == "I"
  @players[name].cards.in_discard.destroy_all
  @discard_contents[name] = []
end

# Matches:
#   I have Smithy in discard
#   I have Smithy, Witch in discard
#   Bob has Smithy, Witch and 4 other cards in discard
#   I have Smithy and 4 other cards named "rest of discard" in discard
Given(/^(\w*) ha(?:ve|s) #{CardList}(?: and )?#{NamedRandCards}? in discard/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'I'
  player = @players[name]
  player.cards.in_discard.destroy_all

  fixed_list ||= ""
  fixed_list.split(/,\s*/).each do |kind|
    num = 1
    card_name = kind
    if /(.*) ?x ?(\d+)/ =~ kind
      card_name = $1.rstrip
      num = $2.to_i
    end
    
    num.times do
      @discard_contents[name] << card_name
      CARD_TYPES[card_name].create(:location => 'discard', :player => player, :game => player.game)
    end
  end
  
  @named_cards[rand_name] = [] if rand_name
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    @discard_contents[name] << type
    @named_cards[rand_name].andand << type
    CARD_TYPES[type].create(:location => 'discard', :player => player, :game => player.game)
  end
  
  player.renum(:discard)
end

# Matches:
#   I have Lighthouse as a duration
#   I have Lighthouse, Wharf as durations
#   Bob has Lighthouse, Wharf and 4 other cards as durations
#   I have Lighthouse and 4 other cards named "rest of durations" as durations
Given(/^(\w*) ha(?:ve|s) #{CardList}(?: and )?#{NamedRandCards}? as (?:a )?durations?/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'I'
  player = @players[name]
  player.cards.enduring.destroy_all

  fixed_list ||= ""
  fixed_list.split(/,\s*/).each do |kind|
    num = 1
    card_name = kind
    if /(.*) ?x ?(\d+)/ =~ kind
      card_name = $1.rstrip
      num = $2.to_i
    end
    
    num.times do
      @enduring_contents[name] << card_name
      CARD_TYPES[card_name].create(:location => 'enduring', :player => player, :game => player.game)
    end
  end
  
  @named_cards[rand_name] = [] if rand_name
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    redo unless CARD_TYPES[type].is_duration?
    @enduring_contents[name] << type
    @named_cards[rand_name].andand << type
    CARD_TYPES[type].create(:location => 'enduring', :player => player, :game => player.game)
  end
  
  player.renum(:enduring)
end

Given(/the (.*) piles? (?:is|are) empty/) do |kinds|
  kinds.split(/,\s*/).each do |kind|
    @game.piles.find(:first, :conditions => {:card_type => CARD_TYPES[kind].name}).cards.delete_all
  end
end

Given(/the (.*) piles? contains? (\d+) cards?/) do |kinds, number|
  number = number.to_i
  kinds.split(/,\s*/).each do |kind|
    pile = @game.piles.find(:first, :conditions => {:card_type => CARD_TYPES[kind].name})
    if pile.cards.count < number
      flunk "Don't support growing pile yet"
    end
    
    pile.cards[number..-1].each(&:delete)
  end
end