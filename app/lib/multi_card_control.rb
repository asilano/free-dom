class MultiCardControl < Control
  attr_reader :key, :preselect

  def initialize(opts = {})
    super
    @filter = filter_from(opts[:filter]) || ->(_card) { true }
    @preselect = opts[:preselect] || ->(_card) { false }
    if opts.key? :submit_text
      @cardless_button = { text: opts[:submit_text],
                           value: '',
                           key: 'submit' }
    end
  end
end
