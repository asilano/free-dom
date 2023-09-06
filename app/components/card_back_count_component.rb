# frozen_string_literal: true

class CardBackCountComponent < ViewComponent::Base
  def initialize(cards:)
    super
    @cards = cards
  end

  private

  attr_reader :cards
end
