class Journal < ActiveRecord::Base
  belongs_to :game
  belongs_to :player

  def =~(ptn)
    event =~ ptn
  end
end