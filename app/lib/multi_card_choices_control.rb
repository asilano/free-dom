class MultiCardChoicesControl < Control
  attr_reader :key, :filter, :preselect, :choices

  def initialize(opts = {})
    super
    @filter = filter_from(opts[:filter]) || ->(_card) { true }
    @preselect = opts[:preselect] || ->(_card) { false }
    @choices = opts[:choices]
    if opts.key? :submit_text
      @cardless_button = { text:  opts[:submit_text],
                           value: '',
                           key:   'submit' }
    end
  end
end
