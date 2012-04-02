Then /the following (\d+) steps should happen at once/ do |num|
  @skip_card_checking = num.to_i
end

Given /^PENDING/ do
  pending
end