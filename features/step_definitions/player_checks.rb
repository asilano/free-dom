Then /I should have (\d+) cash/ do |cash|
  assert_equal cash.to_i, @me.reload.cash
end