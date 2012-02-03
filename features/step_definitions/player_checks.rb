Then /I should have (\d+) cash/ do |cash|
  assert_equal cash.to_i, @me.reload.cash
end

Then /my score should be (-)?(\d+)/ do |neg, score|
  exp = score.to_i
  exp = -exp if neg
  assert_equal exp, @me.reload.score
end