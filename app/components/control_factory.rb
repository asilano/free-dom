# frozen_string_literal: true

class ControlFactory
  class UnknownControlError < TypeError; end

  def self.component_from(control)
    case control
    in OneCardControl
      Controls::OneCardControlComponent
    else
      raise UnknownControlError, "Unknown control type: #{control}"
    end
  end
end
