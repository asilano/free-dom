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
    q = params[:journal]::Question.new
    object = params[:object]
    actor = params[:actor]
    templ = params[:journal]::Template.new(actor, params[:expect])
    @questions << { question: q, object: object, template: templ }
    q
  end

  def expects_journal(journal)
    return false if !unblocked?
    @questions.any? { |q| q[:template].matches?(journal) }
  end

  def apply_journal(journal)
    apply_to, index = @questions.each_with_index.detect do |q, ix|
      q[:template].matches?(journal)
    end

    if apply_to
      # Found a question that wants it
      questions.delete_at(index) unless index.nil?
      journal.invoke(apply_to[:object])
    end

    check_finished
  end

  def unblocked?
    @children.empty? || children.all? { |child| child.questions.empty? && child.unblocked? }
  end

  def check_finished
    @children.each(&:check_finished)
    if @children.empty? && @questions.empty? && @parent
      Rails.logger.info("Finished")
      @parent.children.delete(self)
      @parent.check_finished
    end
  end

  def log(indent = 0)
    Rails.logger.info(" " * indent + "- Strand: Qs = #{@questions.map(&:text)} ")
    @children.each {|c| c.log(indent + 2)}
  end
end
