# Matches:
#   my hand contains Smithy
#   my hand contains Smithy, Witch
#   my hand contains Smithy and 4 other cards named "rest of hand"
Given(/my hand contains ((?:(?:#{CARD_NAMES.join('|')})(?:, )?)*)(?: and )?(?:(\d+) (?:other )?cards?(?: named "(.*)")?)?/) do |fixed_list, num_rand, rand_name|
  @me.cards.hand.destroy_all

  @hand_contents = {:fixed => fixed_list.split(/,\s*/)}
  @hand_contents[:fixed].each do |card_name|
    CARD_TYPES[card_name].create(:location => 'hand', :player => @me, :game => @me.game)
  end
  
  rand_name ||= "rest of hand"
  @hand_contents[rand_name] = []
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    @hand_contents[rand_name] << type
    CARD_TYPES[type].create(:location => 'hand', :player => @me, :game => @me.game)
  end
  
  @me.renum(:hand)
  
  Rails.logger.info("Created hand: #{@hand_contents.inspect}")
  Rails.logger.info("Hand is: #{@me.cards.hand.join(', ')}")
end

Given /my deck is empty/ do
  @me.cards.deck.destroy_all
  @deck_contents = {}
end

# Matches "my deck contains <top> then <middle> then <bottom>". Either of the middle and bottom sections may be missing
# Each section may be like "Smithy, Witch" or like "4 other cards (named "rest of deck")"
Given(/my deck contains (?:(\d+ cards?(?: named ".*")?|(?:(?:#{CARD_NAMES.join('|')})(?:, )?)*) then )?(?:(\d+ (?:other )?cards?(?: named ".*")?|(?:(?:#{CARD_NAMES.join('|')})(?:, )?)*) then )?(?:(\d+ (?:other )?cards?(?: named ".*")?|(?:(?:#{CARD_NAMES.join('|')})(?:, )?)*))?/) do |top, middle, bottom|
  @me.cards.deck.destroy_all
  rand_top = rand_mid = fixed_bottom = false
  
  rand_top = (top =~ /(\d+) cards?(?: named "(.*)")?/)
  num_rand_top = $1
  @name_rand_top = $2 || "top of deck"
  rand_mid = (middle =~ /(\d+) (?:other )?cards?(?: named "(.*)")?/)
  num_rand_mid = $1
  @name_rand_mid = $2 || "mid of deck"
  rand_bottom = (bottom =~ /(\d+) (?:other )?cards?(?: named "(.*)")?/)
  num_rand_bottom = $1
  @name_rand_bottom = $2 || "bottom of deck"
  
  position = 0
  @deck_contents = {}
  
  @deck_contents[:fixed_top] = []
  if rand_top
    @deck_contents[@name_rand_top] = []
    num_rand_top.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[@name_rand_top] << type
      CARD_TYPES[type].create(:location => 'deck', 
                              :player => @me,
                              :position => position, 
                              :game => @me.game)
      position += 1
    end
  elsif top && !rand_top
    @deck_contents[:fixed_top] = top.split(/,\s*/)
    @deck_contents[:fixed_top].each do |card_name|
      CARD_TYPES[card_name].create(:location => 'deck', 
                                   :player => @me,
                                   :position => position, 
                                   :game => @me.game)
      position += 1                             
    end
  end
  
  @deck_contents[:fixed_mid] = []
  if rand_mid
    @deck_contents[@name_rand_mid] = []
    num_rand_mid.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[@name_rand_mid] << type
      CARD_TYPES[type].create(:location => 'deck', 
                              :player => @me,
                              :position => position, 
                              :game => @me.game)
      position += 1
    end
  elsif middle && !rand_mid
    @deck_contents[:fixed_mid] = middle.split(/,\s*/)
    @deck_contents[:fixed_mid].each do |card_name|
      CARD_TYPES[card_name].create(:location => 'deck', 
                                   :player => @me,
                                   :position => position, 
                                   :game => @me.game)
      position += 1                             
    end
  end
  
  @deck_contents[:fixed_bottom] = []
  if rand_bottom
    @deck_contents[@name_rand_bottom] = []
    num_rand_bottom.to_i.times do |i|
      type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
      @deck_contents[@name_rand_bottom] << type
      CARD_TYPES[type].create(:location => 'deck', 
                              :player => @me,
                              :position => position, 
                              :game => @me.game)
      position += 1
    end
  elsif bottom && !rand_bottom
    @deck_contents[:fixed_bottom] = bottom.split(/,\s*/)
    @deck_contents[:fixed_bottom].each do |card_name|
      CARD_TYPES[card_name].create(:location => 'deck', 
                                   :player => @me,
                                   :position => position, 
                                   :game => @me.game)
      position += 1                             
    end
  end
  
  @me.renum(:deck)
  
  Rails.logger.info("Created deck: #{@deck_contents.inspect}")
  Rails.logger.info("Deck is: #{@me.cards.deck.join(', ')}")
end
  
Given /I have nothing in play/ do
  @me.cards.in_play.destroy_all
end

Given /I have nothing in discard/ do
  Rails.logger.info("Clearing discard")
  @me.cards.in_discard.destroy_all
end

Given(/I have ((?:(?:#{CARD_NAMES.join('|')})(?:, )?)*)(?: and )?(?:(\d+) (?:other )?cards?(?: named "(.*)")?)? in discard/) do |fixed_list, num_rand, rand_name|
  @me.cards.in_discard.destroy_all

  @discard_contents = {:fixed => (fixed_list.try(:split, /,\s*/) || [])}
  @discard_contents[:fixed].each do |card_name|
    CARD_TYPES[card_name].create(:location => 'discard', :player => @me, :game => @me.game)
  end
  
  rand_name ||= "rest of discard"
  @discard_contents[rand_name] = []
  num_rand.to_i.times do |i|
    type = CARD_TYPES.keys[rand(CARD_TYPES.length)]
    @discard_contents[rand_name] << type
    CARD_TYPES[type].create(:location => 'discard', :player => @me, :game => @me.game)
  end
  
  @me.renum(:discard)
  
  Rails.logger.info("Created discard: #{@discard_contents.inspect}")
  Rails.logger.info("Discard is: #{@me.cards.in_discard.join(', ')}")
end