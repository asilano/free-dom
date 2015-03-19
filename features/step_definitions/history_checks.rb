Then /later history should include "(.*)"/ do |expected|
  expected.gsub!(/\[I\]/, 'Alan')
  assert_contains @test_game.histories.where(['id > ?', @last_hist_id]).map(&:event), expected
end