class Settings < ActiveRecord::Base
  PermittedFields = [:automoat, :autocrat_victory, :update_interval,
                      :autobaron, :autotorture_curse, :automountebank,
                      :autotreasury, :autoduchess, :autofoolsgold,
                      :autooracle, :autoscheme, :autotunnel,
                      :autobrigand, :autoigg]

  ASK = 0
  ALWAYS = 1
  NEVER = 2

  AskAlwaysNever = {"Ask" => ASK, "Always" => ALWAYS, "Never" => NEVER}

  belongs_to :user
  belongs_to :player

  validates :update_interval, :numericality => {:greater_than_or_equal_to => 60}
  validates :autoduchess, :inclusion => {:in => [ASK, ALWAYS, NEVER]}
  validates :autofoolsgold, :inclusion => {:in => [ASK, ALWAYS, NEVER]}

  alias_attribute :autocrat, :autocrat_victory

end
