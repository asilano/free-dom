class Chat < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  belongs_to :turn_player, :class_name => "Player"
end
