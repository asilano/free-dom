# frozen_string_literal: true

module Controls
  class CardlessButtonComponent < ViewComponent::Base
    include ControlCommon

    with_collection_parameter :button

    def initialize(button:, control:)
      super
      @button = button
      @control = control
    end

    def name = "journal[params][#{button[:key] || control.key}]"

    private

    attr_reader :button, :control
  end
end
