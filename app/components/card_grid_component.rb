# frozen_string_literal: true

class CardGridComponent < ViewComponent::Base
  def initialize(cards:, controls: nil, stacked: false)
    super
    @cards = cards
    @controls = controls
    @stacked = stacked
  end

  def stacked
    return false if cards.count < 2 || controls.present?
    @stacked
  end

  def extra_grid_classes
    [
      ("reorder-cards" if controls.any?(ReorderCardsControl))
    ].compact
  end

  def grid_stimulus_controller
    "sortable-cards" if controls.any?(ReorderCardsControl)
  end

  private

  attr_reader :cards, :controls
end
