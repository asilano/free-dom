# frozen_string_literal: true

module Controls
  class CardlessButtonComponent < ViewComponent::Base
    with_collection_parameter :button

    def initialize(button:, control:)
      super
      @button = button
      @control = control
    end

    private

    attr_reader :button, :control
  end
end
