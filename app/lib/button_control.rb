class ButtonControl < Control
  attr_reader :key, :values

  def initialize(opts = {})
    super
    raise ArgumentError, 'ButtonControl must have values' unless opts.key? :values
    @values = opts[:values]
    @key = opts[:key] || 'choice'
  end
end