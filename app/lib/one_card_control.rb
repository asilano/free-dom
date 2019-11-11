class OneCardControl < Control
  attr_reader :key, :filter

  def initialize(opts = {})
    super
    @filter = opts[:filter] || ->(_card) { true }
    @cardless_button = opts[:null_choice]
  end
end
