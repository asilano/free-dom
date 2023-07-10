# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  renders_many :controls,
    -> (control:) {
      ControlFactory.component_from(control).new(control: ,
                                                 card: @card,
                                                 value: @card_counter)
    }

  def initialize(card:, card_counter:, stacked: false)
    super
    @card = card
    @card_counter = card_counter
    @stacked = stacked
  end

  private

  attr_reader :card, :card_counter, :stacked

  def css_classes
    @card.types + [stacked && "stacked"]
  end
end
