# frozen_string_literal: true

class CardGridComponent < ViewComponent::Base
  def initialize(cards:, controls:)
    super
    @cards = cards
    @controls = controls
  end

  private

  attr_reader :cards, :controls
end
