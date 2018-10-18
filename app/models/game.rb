class Game < ApplicationRecord
  validates :name, presence: true
end
