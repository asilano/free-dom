# frozen_string_literal: true

module Controls
  module ControlCommon
    def name = "journal[params][#{control.key}]"

    def form_id = "control_form_#{control.object_id}"
  end
end
