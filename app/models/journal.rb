class Journal < ActiveRecord::Base
  include CardsHelper

  extend FauxField

  belongs_to :game
  belongs_to :player
  serialize :parameters

  faux_field [:histories, []], :css_class
  attr_accessor :deferred

  after_initialize :blank_histories
  before_save :set_order

  class_attribute :question_defined
  self.question_defined = false
  def self.inherited(subclass)
    super

    subclass.const_set('Question', Class.new do
      def initialize(actor)
      end

      def text
        ''
      end

      def determine_controls
      end
    end)

    subclass.const_set('Template', Class.new do
      attr_reader :actor

      def initialize(actor, args)
        @actor = actor
        @required_args = args || []
      end

      def matches?(journal)
        return false unless self.class == journal.class::Template
        return false unless @actor == journal.player
        return false unless @required_args.all? do |key, val|
          journal.parameters.key?(key) &&
            journal.parameters[key] == val
        end

        true
      end
    end)
  end

  def self.question(opts = {}, &determine)
    raise 'Double question definition' if question_defined
    self.question_defined = true
    remove_const(:Question)
    const_set('Question', Class.new(Question) do
      def initialize(actor)
        @actor = actor
      end

      define_method(:text) do
        case opts[:text]
        when String
          opts[:text]
        when Proc
          instance_exec(&opts[:text])
        end
      end

      determine ||= -> {}
      define_method(:determine_controls) do
        ret = @actor.instance_exec(&determine)
        ret.values.each { |v| v[:journal_type] = self.class.to_s.deconstantize }
        ret
      end
    end)

    self::Question
  end

  class_attribute :cause_method
  def self.causes(meth)
    self.cause_method = meth
  end

  def invoke(object)
    object.public_send(self.class.cause_method, self)
  end

  def self.text(string = nil, &block)
    if string
      define_method(:text) { string }
    else
      define_method(:text, &block)
    end
  end

  def hack_journal?
    false
  end

  def card
    game.find_card(parameters[:card_id]) if parameters[:card_id]
  end

  def cards
    parameters[:card_id].map { |cid| game.find_card(cid) } if parameters[:card_id]
  end

  class Template
    def initialize(args)
    end
  end

  private

  def blank_histories
    self.histories = []
  end

  def set_order
    if !self.order
      self.order = game.journals.any? ? game.journals.map(&:order).max + 1 : 1
    end
  end
end
