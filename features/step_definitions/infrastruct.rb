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
