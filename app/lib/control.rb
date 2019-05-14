class Control
  attr_reader :scope, :player

  def initialize(opts = {})
    raise ArgumentError, 'Control must have a scope' unless opts.key? :scope
    raise ArgumentError, 'Control must have an player' unless opts.key? :player
    @scope = opts[:scope]
    @player = opts[:player]
  end
end