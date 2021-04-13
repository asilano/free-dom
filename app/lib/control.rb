class Control
  attr_reader :journal_type, :question, :scope, :player, :cardless_button, :key, :text, :css_class
  attr_accessor :fiber_id

  def initialize(opts = {})
    raise ArgumentError, 'Control must have a journal type' unless opts.key? :journal_type
    raise ArgumentError, 'Control must have a scope' unless opts.key? :scope
    raise ArgumentError, 'Control must have a player' unless opts.key? :player
    @journal_type = opts.delete(:journal_type)
    @question = opts.delete(:question)
    @fiber_id = opts.delete(:fiber_id)
    @scope = opts.delete(:scope)
    @player = opts.delete(:player)
    @game_state = @player.game_state
    @text = opts.delete(:text) || 'Choose'
    @key = opts.delete(:key) || 'choice'
    @css_class = " #{opts.delete(:css_class)}" || ''
  end

  def to_partial_path
    "controls/#{self.class.name.demodulize.underscore}"
  end

  def single_answer?(_)
    false
  end

  def single_answer
    nil
  end

  def filter_from(option)
    return nil unless option

    if option.is_a? Symbol
      ->(obj) { obj.send(option) }
    else
      option
    end
  end

  def filter(*args)
    instance_exec(*args, &@filter)
  end

  private

  def opts
    @question.opts
  end
end