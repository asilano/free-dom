class Ranking < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :new_result_elo, :new_score_elo
  
  K_VALUE = 16.0
  
  # Update the rankings for the users representing each of the supplied players.
  # Done as a Class function of Ranking because of the fun of pairwise ELO
  # calculations!
  def self.update_rankings(players)
    # Archive off the old values
    players.each do |ply|
      rank = ply.user.ranking
      rank.last_num_won = rank.num_won
      rank.last_total_norm_pos = rank.total_normalised_pos
      rank.last_total_score = rank.total_score
      rank.last_result_elo = rank.result_elo
      rank.last_score_elo = rank.score_elo
      rank.save!
    end
    
    # First, handle the easy stuff - the stuff dependant only on a single player
    # at once. Make sure we give players with the same score the same record.
    groups = players.group_by(&:score)
    distincts = groups.keys.length
    groups.keys.sort.reverse.each_with_index do |key, pos|
      groups[key].each do |ply|
        ranks = ply.user.ranking
        ranks.num_played += 1
        ranks.num_won += 1 if pos == 0
        
        # Normalised position is your position mapped down onto [0,1], with
        # the winner being 0, and last place being 1.
        normalised_pos = (pos == 0 ? 0 : pos.to_f / (distincts - 1) ) 
        ranks.total_normalised_pos += normalised_pos
        
        ranks.total_score += ply.score
      end
    end
    
    players.each do |ply|
      ply.user.ranking.new_result_elo = ply.user.ranking.result_elo
      ply.user.ranking.new_score_elo = ply.user.ranking.score_elo
    end
    
    # Set the K-values to use for this game; divide the master K-value by
    # the number of pairings each player will undergo.    
    k_value = K_VALUE / (players.length - 1)
    k_score_pow = Math.log(k_value)/Math.log(6)
    
    players.combination(2).each do |pair|
      ranks = pair.map {|p| p.user.ranking}
      scores = pair.map {|p| p.score}
      
      # Result based Elo. This is how Elo normally works - rankings are adjusted
      # dependant only on whether the players won or lost.
      exp_a = 1.0 / (1.0 + 10 ** ((ranks[1].result_elo - ranks[0].result_elo)/400.0))
      exp_b = 1.0 / (1.0 + 10 ** ((ranks[0].result_elo - ranks[1].result_elo)/400.0))
      raise "Woah, trippy Elo maths" if (1.0 - exp_a - exp_b) > 0.001
      result_a = (scores[0] <=> scores[1]) / 2.0 + 0.5
      result_b = 1 - result_a
      ranks[0].new_result_elo += k_value * (result_a - exp_a)
      ranks[1].new_result_elo += k_value * (result_b - exp_b)
      
      # Score based Elo. This is my somewhat experimental extension. The K-value
      # used is exponential based on the score differential, with the constant exponent
      # chosen to make a score differential of 6 provide the same K-value as the
      # Result Elo. A finger-in-air sampling of recent games implies 3 points usually
      # separates each pair of players, so this is designed to even out over a 4-player
      # game.
      score_diff = (scores[0] - scores[1]).abs
      ranks[0].new_score_elo += (score_diff ** k_score_pow) * (result_a - exp_a)
      ranks[1].new_score_elo += (score_diff ** k_score_pow) * (result_b - exp_b)
    end
    
    # Finally, update the stored Elos to the new Elos, and save
    players.each do |ply|
      ply.user.ranking.result_elo = ply.user.ranking.new_result_elo
      ply.user.ranking.score_elo = ply.user.ranking.new_score_elo
      ply.user.ranking.save!
    end
  end
  
  def mean_norm_pos
    return (num_played == 0 ? 1 : total_normalised_pos / num_played)
  end
  
  def last_mean_norm_pos
    return (num_played <= 1 ? 1 : last_total_norm_pos / (num_played - 1))
  end
  
  def mean_score
    return (num_played == 0 ? 0 : total_score.to_f / num_played)
  end
  
  def last_mean_score
    return (num_played <= 1 ? 0 : last_total_score.to_f / (num_played - 1))
  end
end
