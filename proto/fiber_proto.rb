# This file contains prototype code acting as proof-of-concept for running a game with journals, posting via Fiber coroutines.
require 'byebug'

# Game is a database object and holds _only_ persistent data. It has references to
# * the in-memory GameState object
# * the in-database Player objects (games-users join)
#   - in turn, contains only persistent data (such as ref-to-Settings)
#   - may contain in-memory PlayerState, also linked to GameState?
# * the in-database Journal array
class Game
  attr_accessor :game_state   # Non-database
  attr_accessor :journals     # Database

  def process
    @game_state = GameState.new
    fiber = Fiber.new { @game_state.run }
    qn = fiber.resume
    @journals.each { |j| qn = fiber.resume(j) }
    qn
  end
end

# GameState is the in-memory record of the game. It applies journals to itself,
# to update the game's state.
class GameState
  class UnexpectedJournalError < ArgumentError
  end

  def run
    # Initialise
    @a = 1

    # Main loop. Ask for an operation
    loop do
      choose_op = get_journal(ChooseOperationJournal)
      case choose_op.choice
      when 'quit'
        puts 'OkILoveYouBuhBye'
        break
      when 'add'
        add_to_a
      when 'multiply'
        multiply_a
      when 'add-sub'
        add_and_subtract
      end

      puts "a is #{@a}"
    end
  end

  private

  def add_to_a
    add_operand = get_journal(GiveOperandJournal, purpose: 'add to a')
    @a += add_operand.operand.to_i
  end

  def multiply_a
    mult_operand = get_journal(GiveOperandJournal, purpose: 'multiply a')
    @a *= mult_operand.operand.to_i
  end

  def add_and_subtract

  end

  def get_journal(journal_class, opts = {})
    journal = Fiber.yield(journal_class.with(opts).question)
    raise UnexpectedJournalError, "Unexpected journal: #{journal}" unless journal_class.with(opts).matches journal
    journal
  end
end

class Journal
  class Template
    attr_reader :opts

    def initialize(opts)
      @opts = opts
    end

    def question
      self.class::Question.new(@opts)
    end

    def matches(journal)
      return false unless journal.is_a? self.class::Parent
      define_singleton_method(:journal) { journal }
      valid?
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
    end
  end

  def self.inherited(subclass)
    subclass.const_set('Template', Class.new(Template))
    subclass::Template.const_set('Parent', subclass)
  end

  def self.define_question(text, &controls)
    self::Template.const_set('Question', Class.new(Template::Question))
    self::Template::Question.const_set('Parent', self)
    self::Template::Question.define_method(:text) { text }
    if controls
      self::Template::Question.define_method(:controls, &controls)
    end
  end

  def self.with(opts)
    self::Template.new(opts)
  end

  def self.validation(&block)
    self::Template.define_method(:valid?, &block)
  end
end

class ChooseOperationJournal < Journal
  attr_reader :choice

  def initialize(value)
    @choice = value
  end

  define_question 'Please choose an operation.' do
    puts ' * add: add a number to @a'
    puts ' * multiply: multiply @a by a number'
    puts ' * quit: stop running'
  end

  validation do
    %w[add multiply quit].include? journal.choice
  end
end

class GiveOperandJournal < Journal
  attr_reader :operand

  def initialize(value)
    @operand = value
  end

  define_question 'Please enter an operand.' do
    puts "This value will be used to: #{opts[:purpose]}"
  end

  validation do
    !!Integer(journal.operand)
  rescue
    false
  end
end
game = Game.new
game.journals = []
loop do
  puts 'Starting to run game'
  qn = game.process
  break unless qn

  puts qn.text
  qn.controls
  game.journals << qn.answer(gets.chomp)
  puts
end