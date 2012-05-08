require 'digest/sha1'

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :contact_me, :pbem

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  #attr_accessor :password_confirmation
  validates :password, :confirmation => true
  #validate :password_non_blank
  validates :hashed_password, :presence => true
  validates :password_confirmation, :presence => {:if => :hashed_password_changed?}
  validates :email, :presence => true, :uniqueness => true, :format => /^$|^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i
  
  has_many :players, :dependent => :destroy
  has_many :games, :through => :players
  has_one :settings, :dependent => :destroy
  accepts_nested_attributes_for :settings
  has_one :ranking, :dependent => :destroy
  
  before_validation :downcase_email
  
  before_create :create_settings, :create_ranking
  
  def self.cookie_timeout
    30
  end
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  def self.authenticate(name, password)
    user = self.find_by_name(name)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
  
  def hashed_email(start=4,len=18)
    # Take a chunk of the digest only. 
    Digest::SHA1.hexdigest(email)[start,len]
  end
  
  def reset_password
    new_pass = random_password
    self.password = new_pass
    self.password_confirmation = new_pass
    save!
    return new_pass
  end
  
private
  
  def password_non_blank
    errors.add(:password, "is missing" ) if hashed_password.blank?
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "d0m!n1On" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def downcase_email
    self.email = self.email.downcase if self.email.present?
  end
  
  def random_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end

end
