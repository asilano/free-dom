class Game < ApplicationRecord
  has_many :journals, -> { order :order }, dependent: :destroy, inverse_of: :game
  has_many :users, -> { unscope(:order).distinct }, through: :journals

  accepts_nested_attributes_for :journals

  attr_reader :game_state, :question

  # Execute the game's journals in memory.
  def process
    # Spawn a GameState object, seeding it with our creating time
    # in nanoseconds
    @game_state = GameEngine::GameState.new(created_at.nsec)

    # Prepare a Fiber to run the game state in a coroutiney way
    fiber = Fiber.new { @game_state.run }

    # Kick the fiber off, and wait for the first question
    @question = fiber.resume

    # Until we run out of answers, post journals in as answers to questions
    journals.each { |j| @question = fiber.resume(j) }
  end
end
