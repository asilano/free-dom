class Journal < ActiveRecord::Base
  extend FauxField

  belongs_to :game
  belongs_to :player
  serialize :parameters

  faux_field [:histories, []], :css_class
  attr_accessor :deferred

  validate :parameters_ok?

  after_initialize :blank_histories
  before_save :set_order

  class_attribute :question_defined
  self.question_defined = false
  def self.inherited(subclass)
    super

    subclass.const_set('Question', Class.new do
      def text
        ''
      end

      def determine_controls(actor, controls)
      end
    end)

    subclass.const_set('Template', Class.new do
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
    const_set('Question', Class.new do
      define_method(:text) { opts[:text] || '' }

      determine ||= ->(actor, controls) {}
      define_method(:determine_controls, &determine)
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

  # def =~(ptn)
  #   event =~ ptn
  # end

  # def card_error(error)
  #   errors.add(:base, "card_#{error}".to_sym)
  # end

  # def add_history(params)
  #   self.histories << History.new(params)
  # end

  # class Template
  #   attr_reader :template
  #   def initialize(templ)
  #     @template = templ
  #   end

  #   def fill(fields)
  #     @template.gsub(/{{(.*?)}}/) do |m|
  #       field = fields[$1.to_sym]
  #       if field.kind_of? Array
  #         field = field.join(', ')
  #       end

  #       field || "{{#{$1}}}"
  #     end
  #   end

  #   def match(*args)
  #     to_re.match(*args)
  #   end

  #   def to_re
  #     pattern = @template.gsub(/{{(.*?)}}/) { |m| "(?<#{$1}>.*)" }
  #     Regexp.new pattern
  #   end
  # end

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

  def parameters_ok?
    true
  end
end
