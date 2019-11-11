# This file contains prototype code acting as proof-of-concept for running a game with journals.
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
    @journals.each do |journal|
      @game_state.handle(journal)
    end

    unless @game_state.ended
      @game_state.question
    end
  end
end

# GameState is the in-memory record of the game. It applies journals to itself,
# to update the game's state.
class GameState
  attr_reader :a, :ended

  def initialize
    @a = 1  # Just some "game state data" to act upong
    @ended = false
    @waiting_for = StartGameJournal.template
  end

  def handle(journal)
    # Error if this journal is unexpected
    raise Journal::UnexpectedJournalError, "Unexpected #{journal.text}" unless expecting journal
    journal.invoke(self)
  end

  # Return the current unanswered question to be asked to the player
  def question
    @waiting_for.question
  end

  ############
  # State-mutating methods, prompted by acting on journals
  ############
  def start_game(journal)
    @waiting_for = ChooseOperationJournal.template
  end

  def say_operation(journal)
    puts "You chose to #{journal.operation}"
    @ended = true
  end

  private

  # Return whether self is currently expecting to receive this journal
  def expecting(journal)
    @waiting_for.matches journal
  end
end

# Base class for all journals. Contains some fun metaprogramming stuff.
class Journal
  class UnexpectedJournalError < ArgumentError
  end

  # Base class for nested templates, to match against
  class Template
    # At a basic level, a journal matches a template being waited for
    # if it's of the right Journal subclass
    def matches(journal)
      journal.is_a? self.class::PARENT
    end

    def question
      self.class::PARENT::Question.new
    end
  end

  # Base calss for nested Questions, used to present options to the
  # player and build journals from the answers
  class Question
    def answer(value)
      self.class::PARENT.new(value)
    end
  end

  # Currently unused; _text_ would be what shows up in the journal log
  # for front-end display
  def text
    'Journal base class'
  end

  # To invoke a journal on an object (here, GameState; but in the full game
  # probably the owning card object) is to call the method on that object
  # as configured on the Journal subclass.
  def invoke(object)
    object.send(causes, self)
  end

  # Whenever a new journal subclass is defined, this gets called, automatically
  # creating a Template nested class
  def self.inherited(subclass)
    super

    # Define a matching, nested Template class to match the subclass.
    subclass.const_set('Template', Class.new(Template))
    subclass::Template.const_set('PARENT', subclass)
  end

  # Set up the Question nested class with supplied question text
  def self.question(text)
    const_set('Question', Class.new(Question))
    Question.const_set('PARENT', self)
    Question.define_method(:text) { text }
  end

  # Helper function to return an instance of the nested Template
  def self.template
    self::Template.new
  end
end

class StartGameJournal < Journal
  def text
    'Started game'
  end

  def causes
    :start_game
  end
end

class ChooseOperationJournal < Journal
  attr_reader :operation

  def initialize(choice)
    @operation = choice
  end

  def text
    "Chose #{@choice}"
  end

  question 'Choose an operation from: add, subtract, multiply'

  def causes
    :say_operation
  end
end

game = Game.new
game.journals = [StartGameJournal.new]
loop do
  qn = game.process
  break unless qn

  puts qn.text
  answer = gets.chomp
  game.journals << qn.answer(answer)
end

# At present, this only handles single-path flows - it can't cope with more than one
# question being asked at the same time. This means it's unsuitable even for the base game
# (e.g. Militia). That will be the next step.

# To cope with "discard 1. Draw 1" where discard may trigger a blocking question,
# make draw(1) actually call invoke(:do_draw, 1), and have invoke do nothing (or bail)
# if any children are blocking. Similarly for _everything_
#
# Or! Define a metaprogramming method to define each game action so it checks for blocking
# children before proceeding.