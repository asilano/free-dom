class Settings < ActiveRecord::Base
  belongs_to :user
  belongs_to :player
  
  validates_numericality_of :update_interval
  validate :interval_long_enough
  
  alias_attribute :autocrat, :autocrat_victory
  
protected
  def interval_long_enough
    errors.add(:update_interval, 'must be at least 60 seconds.') if update_interval < 60
  end
  
end
