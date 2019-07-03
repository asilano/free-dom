class ButtonControl < Control
  attr_reader :values

  def initialize(opts = {})
    super
    raise ArgumentError, 'ButtonControl must have values' unless opts.key? :values
    @values = opts[:values]
  end
end