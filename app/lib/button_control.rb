class ButtonControl < Control
  attr_reader :values

  def initialize(opts = {})
    super
    raise ArgumentError, 'ButtonControl must have values' unless opts.key? :values
    @values = opts[:values]
  end

  def single_answer?(_)
    return false if @journal_type == GameEngine::StartGameJournal
    @values.count <= 1
  end

  def single_answer
    @values[0][1]
  end
end
