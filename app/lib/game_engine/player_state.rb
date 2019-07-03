class GameEngine::PlayerState
  attr_reader :user, :deck_cards, :hand_cards
  attr_accessor :seat, :actions, :buys, :cash

  def initialize(user)
    @user = user
    @deck_cards = []
    @hand_cards = []
  end

  def name
    @user.name
  end

  def cards
    @deck_cards + @hand_cards
  end
end