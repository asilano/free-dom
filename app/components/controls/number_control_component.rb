# frozen_string_literal: true

module Controls
  class NumberControlComponent < ViewComponent::Base
    include ControlCommon

    def initialize(control:)
      super
      @control = control
    end

    private

    attr_reader :control
  end
end
