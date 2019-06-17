module GameEngine
  class History
    attr_accessor :event, :css_class

    def initialize(event, css_class: nil)
      @event = event
      @css_class = css_class
    end
  end
end