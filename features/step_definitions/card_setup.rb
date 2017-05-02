# Matches:
#   my hand is empty
#   Bob's hand is empty
Given(/^(\w*?)(?:'s)? hand is empty/) do |name|
  name = 'Alan' if name == 'my'
  @hand_contents[name] = []
  hack_journal = "Hack: #{name} hand = "
  @test_game.add_journal(event: hack_journal)
  @test_game.process_journals
end

# Matches:
#   my hand contains Smithy
#   my hand contains Smithy, Witch
#   Bob's hand contains Smithy, Witch and 4 other cards
#   my hand contains Smithy and 4 other cards named "rest of hand"
Given(/^(\w*?)(?:'s)? hand contains #{CardList}(?: and )?#{NamedRandCards}?/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'my'
  player = @test_players[name]

  fixed_list ||= ""
  @hand_contents[name] = []
  hack_journal = "Hack: #{name} hand = "
  hack_cards = []
  fixed_list.split(/,\s*/).each do |kind|
    num = 1
    card_name = kind
    if /(.*) ?x ?(\d+)/ =~ kind
      card_name = $1.rstrip
      num = $2.to_i
    end

    num.times do
      @hand_contents[name] << card_name
      hack_cards << CARD_TYPES[card_name].name
    end
  end

  @named_cards[rand_name] = [] if rand_name
  nrand = num_rand.to_i
  if nrand > 0
    # Force a treasure into hand for consistency with phase ends
    @hand_contents[name] << 'Copper'
    @named_cards[rand_name].andand << 'Copper'
    nrand -= 1
    hack_cards << 'BasicCards::Copper'
  end

  nrand.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    # Watchtower in hand messes up any test that wants to gain a card
    redo if type == "Watchtower"
    redo if CARD_TYPES[type].is_treasure? && CARD_TYPES[type].is_special?
    @hand_contents[name] << type
    @named_cards[rand_name].andand << type
    hack_cards << CARD_TYPES[type].name
  end

  hack_journal << hack_cards.join(", ")
  @test_game.add_journal(event: hack_journal)
  @test_game.process_journals

end

# Matches:
#   my deck is empty
#   Bob's deck is empty
Given(/^(\w*?)(?:'s)? deck is empty/) do |name|
  name = 'Alan' if name == 'my'
  @deck_contents[name] = []
  @test_game.add_journal(event: "Hack: #{name} deck =")
  @test_game.process_journals
end

# Matches "my deck contains <top> then <middle> then <bottom>". Either of the middle and bottom sections may be missing
# Each section may be like "Smithy, Witch" or like "4 other cards (named "rest of deck")"
Given(/^(\w*?)(?:'s)?? deck contains (?:(#{NamedRandCardsNoMatch}|#{CardListNoCapture}) then )?(?:(#{NamedRandCardsNoMatch}|#{CardListNoCapture}) then )?(?:(#{NamedRandCardsNoMatch}|#{CardListNoCapture}))?/) do |name, top, middle, bottom|
  name = 'Alan' if name == 'my'
  player = @test_players[name]

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

  hack_journal = "Hack: #{name} deck = "
  hack_cards = []

  @named_cards[name_rand_top] = [] if name_rand_top
  if rand_top
    num_rand_top.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[name] << type
      @named_cards[name_rand_top].andand << type
      hack_cards << CARD_TYPES[type].name
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
        hack_cards << CARD_TYPES[card_name].name
      end
    end
  end

  @named_cards[name_rand_mid] = [] if name_rand_mid
  if rand_mid
    num_rand_mid.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[name] << type
      @named_cards[name_rand_mid].andand << type
      hack_cards << CARD_TYPES[type].name
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
        hack_cards << CARD_TYPES[card_name].name
      end
    end
  end

  @named_cards[name_rand_bottom] = [] if name_rand_bottom
  if rand_bottom
    num_rand_bottom.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[name] << type
      @named_cards[name_rand_bottom].andand << type
      hack_cards << CARD_TYPES[type].name
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
        hack_cards << CARD_TYPES[card_name].name
      end
    end
  end

  hack_journal << hack_cards.join(", ")
  @test_game.add_journal(event: hack_journal)
  @test_game.process_journals
end

# Matches:
#   I have nothing in play
#   Bob has nothing in play
Given /^(\w*) ha(?:ve|s) nothing in play/ do |name|
  name = 'Alan' if name == 'I'
  @play_contents[name] = []
  @test_game.add_journal(event: "Hack: #{name} play =")
  @test_game.process_journals
end

# Matches:
#   I have Smithy in play
#   I have Smithy, Witch in play
#   Bob has Smithy, Witch and 4 other cards in play
#   I have Smithy and 4 other cards named "rest of play" in play
Given(/^(\w*) ha(?:ve|s) #{CardList}(?: and )?#{NamedRandCards}? in play/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'I'
  player = @test_players[name]

  hack_journal = "Hack: #{name} play = "
  hack_cards = []
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
      hack_cards << CARD_TYPES[card_name].name
    end
  end

  @named_cards[rand_name] = [] if rand_name
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    redo if %w<Royal\ Seal Talisman>.include?(type) # Royal Seal and Talisman in play mess up gaining cards
    @play_contents[name] << type
    @named_cards[rand_name].andand << type
    hack_cards << CARD_TYPES[card_name].name
  end

  hack_journal << hack_cards.join(", ")
  @test_game.add_journal(event: hack_journal)
  @test_game.process_journals
end

# Matches:
#   I have nothing in discard
#   Bob has nothing in his discard
Given /^(\w*) ha(?:ve|s) nothing in (?:my |his )?discard/ do |name|
  name = "Alan" if name == "I"
  @discard_contents[name] = []
  @test_game.add_journal(event: "Hack: #{name} discard =")
  @test_game.process_journals
end

# Matches:
#   I have Smithy in discard
#   I have Smithy, Witch in my discard
#   Bob has Smithy, Witch and 4 other cards in his discard
#   I have Smithy and 4 other cards named "rest of discard" in discard
Given(/^(\w*) ha(?:ve|s) #{CardList}(?: and )?#{NamedRandCards}? in (?:my |his )?discard/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'I'
  player = @test_players[name]

  hack_journal = "Hack: #{name} discard = "
  hack_cards = []

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
      hack_cards << CARD_TYPES[card_name].name
    end
  end

  @named_cards[rand_name] = [] if rand_name
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    @discard_contents[name] << type
    @named_cards[rand_name].andand << type
    hack_cards << CARD_TYPES[type].name
  end

  hack_journal << hack_cards.join(", ")
  @test_game.add_journal(event: hack_journal)
  @test_game.process_journals
end

# Matches:
#   I have Lighthouse as a duration
#   I have Lighthouse, Wharf as durations
#   Bob has Lighthouse, Wharf and 4 other cards as durations
#   I have Lighthouse and 4 other cards named "rest of durations" as durations
Given(/^(\w*) ha(?:ve|s) #{CardList}(?: and )?#{NamedRandCards}? as (?:a )?durations?/) do |name, fixed_list, num_rand, rand_name|
  name = 'Alan' if name == 'I'
  player = @test_players[name]

  hack_journal = "Hack: #{name} enduring = "
  hack_cards = []

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
      hack_cards << CARD_TYPES[card_name].name
    end
  end

  @named_cards[rand_name] = [] if rand_name
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    redo unless CARD_TYPES[type].is_duration?
    @enduring_contents[name] << type
    @named_cards[rand_name].andand << type
    hack_cards << CARD_TYPES[type].name
  end

  hack_journal << hack_cards.join(", ")
  @test_game.add_journal(event: hack_journal)
  @test_game.process_journals
end

Given(/the (.*) piles? (?:is|are) empty/) do |kinds|
  kinds.split(/,\s*/).each do |kind|
    @test_game.add_journal(event: "Hack: #{CARD_TYPES[kind].name} in pile remove all")
    @test_game.process_journals
  end
end

Given(/the (.*) piles? contains? (\d+) cards?/) do |kinds, number|
  number = number.to_i
  kinds.split(/,\s*/).each do |kind|
    pile = @test_game.piles.where { card_type == CARD_TYPES[kind].name}.first
    if pile.cards.count < number
      flunk "Don't support growing pile yet"
    end

    pile.cards[number..-1].each(&:delete)
  end
end
