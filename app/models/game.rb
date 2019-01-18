class Game < ApplicationRecord
  has_many :journals, -> { order :order }, dependent: :destroy
  has_many :users, through: :journals
end
