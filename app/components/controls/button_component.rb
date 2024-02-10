# frozen_string_literal: true

module Controls
  class ButtonComponent < ViewComponent::Base
    def initialize(text:, value:, name:, css_class:, form:)
      super
      @text = text
      @value = value
      @name = name
      @css_class = css_class
      @form = form
    end

    private

    attr_reader :text, :value, :name, :css_class, :form
  end
end
