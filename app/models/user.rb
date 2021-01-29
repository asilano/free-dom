class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :journals
  has_many :games, -> { distinct }, through: :journals

  validates :name, presence: true

  def discord_mention
    name
  end
end
