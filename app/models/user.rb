class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :journals
  has_many :games, -> { distinct }, through: :journals

  validates :name, presence: true
  validates :discord_uid, numericality: true, allow_blank: true

  def discord_mention
    return name if discord_uid.blank?

    "<@#{discord_uid}>"
  end
end
