
class Journal < ActiveRecord::Base
  extend FauxField

  belongs_to :game
  belongs_to :player

  faux_field [:histories, []], :css_class
  attr_accessor :params

  after_initialize :blank_histories
  before_save :set_order

  def =~(ptn)
    event =~ ptn
  end

  def card_error(error)
    errors.add(:base, "card_#{error}".to_sym)
  end

  def add_history(params)
    self.histories << History.new(params)
  end

  class Template
    def initialize(templ)
      @template = templ
    end

    def fill(fields)
      @template.gsub(/{{(.*?)}}/) do |m|
        field = fields[$1.to_sym]
        if field.kind_of? Array
          field = field.join(', ')
        end

        field || "{{#{$1}}}"
      end
    end

    def match(*args)
      to_re.match(*args)
    end

    def to_re
      pattern = @template.gsub(/{{(.*?)}}/) { |m| "(?<#{$1}>.*)" }
      Regexp.new pattern
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