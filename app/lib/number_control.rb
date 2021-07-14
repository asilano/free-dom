class NumberControl < Control
  attr_reader :min, :max

  def initialize(opts = {})
    super
    @min = opts[:min]
    @max = opts[:max]

    @cardless_button = { text:  opts[:submit_text],
                         value: '',
                         key:   'submit' }
  end

  def single_answer?(_)
    @min && @max && @min == @max
  end

  def single_answer
    @min
  end
end
