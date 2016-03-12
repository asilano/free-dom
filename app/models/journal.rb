class Journal < ActiveRecord::Base
  extend FauxField

  belongs_to :game
  belongs_to :player

  faux_field [:histories, []]

  def =~(ptn)
    event =~ ptn
  end

  def card_error(error)
    errors.add(:base, "card_#{error}".to_sym)
  end
end