class OneCardControl < Control
  attr_reader :key, :filter

  def initialize(opts = {})
    super
    @filter = opts[:filter] || ->(_card) { true }
    @cardless_button = { text: opts[:null_choice].first[0],
                         value: opts[:null_choice].first[1] }
  end
end