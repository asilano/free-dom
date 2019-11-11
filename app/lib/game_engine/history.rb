module GameEngine
  class History
    attr_accessor :event, :css_class

    def initialize(event, player: nil, css_classes: [])
      @event = event
      css_classes << "player#{player.seat}" if player
      @css_class = css_classes.join(' ')
    end
  end
end