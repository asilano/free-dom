# frozen_string_literal: true

class ControlFactory
  class UnknownControlError < TypeError; end

  def self.component_from(control)
    case control
    in OneCardControl
      Controls::OneCardControlComponent
    in MultiCardControl
      Controls::MultiCardControlComponent
    in NumberControl
      Controls::NumberControlComponent
    else
      raise UnknownControlError, "Unknown control type: #{control}"
    end
  end
end
