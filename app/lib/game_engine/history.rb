module GameEngine
  class History
    attr_accessor :event, :css_class
    attr_writer :secret

    def initialize(event, player: nil, css_classes: [])
      @event = event
      @secret = false
      css_classes << "player#{player.seat}" if player
      @css_class = css_classes.join(' ')
    end

    def secret?; @secret; end

    def self.new_secret(event, player: nil, css_classes: [])
      new(event, player: player, css_classes: css_classes).tap { |h| h.secret = true }
    end

    def self.personal_log(private_to:, private_msg:, public_msg:)
      "{#{private_to.id}?#{private_msg}|#{public_msg}}"
    end
  end
end