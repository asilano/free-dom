class Journal < ApplicationRecord
  belongs_to :game
  belongs_to :user

  attr_reader :histories

  # Nested classes let GameEngine request the right journal at the right time
  class Template
    attr_reader :opts, :player

    def initialize(player)
      @player = player
    end

    def with(opts)
      @opts = opts
      self
    end

    def question
      self.class::Question.new(@player, @opts)
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
      attr_reader :opts, :player
      def initialize(player, opts)
        @opts = opts
        @player = player
      end

      def journal_type
        self.class::Parent
      end

      def controls(game_state)
        @controls ||= get_controls(game_state)
      end

      def controls_for(user, game_state)
        controls(game_state).select { |ctrl| ctrl.player.user == user }
      end

      def self.with_controls(&controls)
        define_method(:get_controls, &controls)
      end

      private

      def get_controls(_game_state)
        []
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
    self::Template::Question
  end

  def self.from(player)
    self::Template.new(player)
  end

  def self.validation(&block)
    self::Template.define_method(:do_validate, &block)
  end

  def process(_state)
    @histories = []
  end
end
