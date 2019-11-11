class Control
  attr_reader :scope, :player, :cardless_button, :key, :text, :css_class

  def initialize(opts = {})
    raise ArgumentError, 'Control must have a scope' unless opts.key? :scope
    raise ArgumentError, 'Control must have a player' unless opts.key? :player
    @scope = opts[:scope]
    @player = opts[:player]
    @game_state = @player.game_state
    @text = opts[:text] || 'Choose'
    @key = opts[:key] || 'choice'
    @css_class = " #{opts[:css_class]}" || ''
  end

  def to_partial_path
    "controls/#{self.class.name.demodulize.underscore}"
  end
end