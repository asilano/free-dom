# frozen_string_literal: true

module Controls
  class ReorderCardsControlComponent < ViewComponent::Base
    include ControlCommon

    def initialize(control:, card:, value:)
      super
      @control = control
      @card = card
      @value = value
    end

    def render?
      @control.filter(@card)
    end

    def selected?
      @control.preselect.call(@card)
    end

    private

    attr_reader :control, :value, :card
  end
end
