class Settings < ActiveRecord::Base
  belongs_to :user
  belongs_to :player
  
  validates :update_interval, :numericality => {:greater_than_or_equal_to => 60}
  
  alias_attribute :autocrat, :autocrat_victory
  
end
