class Journal < ApplicationRecord
  belongs_to :game
  belongs_to :user

  # Nested classes let GameEngine request the right journal at the right time
  class Template
    attr_reader :opts

    def initialize(opts)
      @opts = opts
    end

    def question
      self.class::Question.new(@opts)
    end

    def matches?(journal)
      journal.is_a? self.class::Parent
    end

    def valid?(journal)
      define_singleton_method(:journal) { journal }
      do_validate
    end

    def do_validate
      true
    end

    class Question
      attr_reader :opts
      def initialize(opts)
        @opts = opts
      end

      def answer(value)
        self.class::Parent.new(value)
      end

      def controls; end

      def with_controls(&controls)
        self::Template::Question.define_method(:controls, &controls)
      end
    end
  end

  # When a Journal subclass is created, give that subclass its own
  # nested Template and Question classes
  def self.inherited(subclass)
    super
    subclass.const_set('Template', Class.new(Template))
    subclass::Template.const_set('Parent', subclass)
  end

  def self.define_question(text = nil, &block)
    raise ArgumentError, 'Supply exactly one of fixed text or text block' unless text.nil? == block_given?
    self::Template.const_set('Question', Class.new(Template::Question))
    self::Template::Question.const_set('Parent', self)
    if text
      self::Template::Question.define_method(:text) { |_| text }
    else
      self::Template::Question.define_method(:text, &block)
    end
  end

  def self.with(opts)
    self::Template.new(opts)
  end

  def self.validation(&block)
    self::Template.define_method(:do_validate, &block)
  end

  def process(_)
    Rails.logger.info("Processing a #{'type'}")
  end
end
