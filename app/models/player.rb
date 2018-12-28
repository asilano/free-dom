class Player < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :game, presence: true
  validates :user, presence: true
  validates :game, uniqueness: { scope: :user }
end
