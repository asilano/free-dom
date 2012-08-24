Given /the game fact "(.*)" is (.*)/ do |fact, value|
  @game.facts_will_change!
  value = value.to_i if value =~ /^\d+$/
  value = nil if value == "nil"
  @game.facts[fact.gsub(/\s/, '_').to_sym] = value
  @game.save
end
