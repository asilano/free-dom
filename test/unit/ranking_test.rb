require File.dirname(__FILE__) + '/../test_helper'

class RankingTest < ActiveSupport::TestCase
  should belong_to :user
  
  should "calculate means correctly" do
    @rank = Factory(:ranking)
    assert_equal 0.25, @rank.mean_norm_pos
    assert_equal 29.8, @rank.mean_score
    assert_equal 0.3125, @rank.last_mean_norm_pos
    assert_equal 29.75, @rank.last_mean_score
  end
  
  context "with players and users" do
    setup do
      stub_game(:create_game, :create_players)
      @user_alan.ranking = Factory(:ranking)
      @ply_alan.score = 10
      @ply_bob.score = 20
      @ply_chas.score = 30
      @players = [@ply_alan, @ply_bob, @ply_chas]
      @players.each(&:save)           
      @users = [@user_alan, @user_bob, @user_chas]
    end
    
    should "update played correctly" do
      before = @users.map(&:ranking).map(&:num_played)
      Ranking.update_rankings(@players)
      assert_equal(before.map {|n| n+1}, @users.map{|u| u.ranking(true)}.map(&:num_played))
    end
    
    should "update won correctly" do
      before = @users.map(&:ranking).map(&:num_won)
      Ranking.update_rankings(@players)
      assert_equal([before[0], before[1], before[2]+1], @users.map{|u| u.ranking(true)}.map(&:num_won))
      assert_equal(before, @users.map{|u| u.ranking(true)}.map(&:last_num_won))
    end
    
    should "update norm pos correctly" do
      before = @users.map(&:ranking).map(&:total_normalised_pos)
      Ranking.update_rankings(@players)
      assert_equal([before[0]+1, before[1]+0.5, before[2]], @users.map{|u| u.ranking(true)}.map(&:total_normalised_pos))
      assert_equal(before, @users.map{|u| u.ranking(true)}.map(&:last_total_norm_pos))
    end
    
    should "update score correctly" do
      before = @users.map(&:ranking).map(&:total_score)
      Ranking.update_rankings(@players)
      assert_equal([before[0]+10, before[1]+20, before[2]+30], @users.map{|u| u.ranking(true)}.map(&:total_score))
      assert_equal(before, @users.map{|u| u.ranking(true)}.map(&:last_total_score))
    end
    
    should "update result ELO correctly" do
      before = @users.map(&:ranking).map(&:result_elo)
      Ranking.update_rankings(@players)
      
      # Don't want to replicate the ELO calculation here, so just check some facts about it.
      elo_alan = @user_alan.ranking(true).result_elo
      elo_bob = @user_bob.ranking(true).result_elo
      elo_chas = @user_chas.ranking(true).result_elo
      
      # Check ELO is zero-sum
      assert_in_delta(0, before.inject(&:+) - (elo_alan + elo_bob + elo_chas), 0.001)
      
      # Chas has a 2-0 record, so his ELO must have increased
      assert elo_chas > before[2], "winner's ELO should always increase"
      
      # Alan has a 0-2 record, so his ELO must have decreased
      assert elo_alan < before[0], "loser's ELO should always decrease"
      
      # Bob has a 1-1 record, so his ELO changes in a direction depending on whether he was more
      # likely to beat Alan or lose to Chas.
      direction = (before[1] - before[0]) - (before[2] - before[1])
      if direction == 0
        assert_in_delta(0, before[1] - elo_bob, 0.001)
      elsif direction > 0
        assert elo_bob < before[1], "expected mid-place player to decrease"
      elsif direction < 0
        assert elo_bob > before[1], "expected mid-place player to increase"
      end
      
      assert_equal(before, @users.map{|u| u.ranking(true)}.map(&:last_result_elo))
    end
    
    should "update score ELO correctly" do
      before = @users.map(&:ranking).map(&:score_elo)
      Ranking.update_rankings(@players)
      
      # Don't want to replicate the ELO calculation here, so just check some facts about it.
      elo_alan = @user_alan.ranking(true).score_elo
      elo_bob = @user_bob.ranking(true).score_elo
      elo_chas = @user_chas.ranking(true).score_elo
      
      # Check ELO is zero-sum
      assert_in_delta(0, before.inject(&:+) - (elo_alan + elo_bob + elo_chas), 0.001)
      
      # Chas has a 2-0 record, so his ELO must have increased
      assert elo_chas > before[2], "winner's ELO should always increase"
      
      # Alan has a 0-2 record, so his ELO must have decreased
      assert elo_alan < before[0], "loser's ELO should always decrease"
      
      # Bob's expectation is not feasible to determine
      
      assert_equal(before, @users.map{|u| u.ranking(true)}.map(&:last_score_elo))
    end
  end
end
