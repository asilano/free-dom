require 'random_namer'
module GamesHelper
  def random_game_name
    RandomNamer::random_name
  end
end
