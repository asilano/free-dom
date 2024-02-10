# frozen_string_literal: true

module Controls
  class MultiCardChoicesControlComponent < ViewComponent::Base
    include ControlCommon

    def initialize(control:, card:, value:, choice: nil)
      super
      @control = control
      @card = card
      @value = value
      @choice = choice || control.choices.first[1]
    end

    def render?
      @control.filter(@card)
    end

    private

    attr_reader :control, :value, :card, :choice
  end
end
