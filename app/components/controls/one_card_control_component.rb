# frozen_string_literal: true

module Controls
  class OneCardControlComponent < ViewComponent::Base
    def initialize(control:, card:, value:)
      super
      @control = control
      @card = card
      @value = value
    end

    def render?
      @control.filter(@card)
    end

    private

    attr_reader :control, :value
  end
end
