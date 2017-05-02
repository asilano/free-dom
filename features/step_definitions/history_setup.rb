Given /I have noted the last history/ do
 @last_hist_time = @test_game.journals.map(&:histories).flatten.last.created_at
end
