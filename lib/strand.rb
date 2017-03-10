class Strand
  attr_reader :questions
  attr_reader :parent
  attr_reader :children

  def initialize(parent = nil)
    @questions = []
    @children = []
    if parent
      @parent = parent
      @parent.children << self
    end
  end

  def ask_question(params)
    q = Question.new(params)
    @questions << q
    q
  end

  def expects_journal(journal)
    @questions.any? do |q|
      if (q.actor != journal.player)
        false
      else
        q.object.send(q.method, journal, q.actor, check: true)
      end
    end
  end

  def apply_journal(journal)
    apply_to, index = @questions.each_with_index.detect do |q, ix|
      if (q.actor != journal.player)
        false
      else
        q.object.send(q.method, journal, q.actor, check: true)
      end
    end

    if apply_to
      # Found a question that wants it
      questions.delete_at(index) unless index.nil?
      journal.params = apply_to.params
      apply_to.object.send(apply_to.method, journal, apply_to.actor)
    end
  end
end
