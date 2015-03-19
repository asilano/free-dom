Given /the game fact "(.*)" is (.*)/ do |fact, value|
  @test_game.facts_will_change!
  value = value.to_i if value =~ /^\d+$/
  value = nil if value == "nil"
  @test_game.facts[fact.gsub(/\s/, '_').to_sym] = value
  @test_game.save
end
