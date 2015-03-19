Then /the following (\d+) steps should happen at once/ do |num|
  @skip_card_checking = num.to_i
end

Then /nothing should have happened/ do
end

Given /^PENDING/ do
  pending
end

Then /dump actions/ do
  PendingAction.all.each {|pa| Rails.logger.info(pa.inspect)}
end

Then /dump controls/ do
    @test_players.each {|name, ply| Rails.logger.info(ply.determine_controls.inspect)}
end

Then /dump hands/ do
    @hand_contents.each {|plr, cards| Rails.logger.info("#{plr}'s hand was: #{cards.inspect}")}
end

Then /dump histories/ do
  History.all.each {|hist| Rails.logger.info(hist.event)}
end
