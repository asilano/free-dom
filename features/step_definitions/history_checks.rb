Then /later history should include "(.*)"/ do |expected|
  expected.gsub!(/\[I\]/, 'Alan')
  assert_contains @test_game.journals.map(&:histories).flatten.select{ |h| h.created_at > @last_hist_time}.map(&:event), expected
end
