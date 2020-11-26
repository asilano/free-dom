class ReorderCardsControl < MultiCardChoicesControl
  def initialize(opts = {})
    raise ArgumentError, 'must supply count:' unless opts.key?(:count)

    choices = (1..opts[:count]).map do |position|
      [position.ordinalize, position]
    end
    choices[0][0] += ' (topmost)'
    choices[-1][0] += ' (bottommost)' unless opts[:count] == 1
    super(opts.merge(choices: choices.to_h))
  end
end