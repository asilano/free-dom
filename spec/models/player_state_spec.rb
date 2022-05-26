require "rails_helper"

RSpec.describe GameEngine::PlayerState, type: :model do
  it "should produce a helpful decklist" do
    player = FactoryBot.build(:player_state)

    player.instance_variable_set :@cards, [
      # All three basic victories in various quantities
      GameEngine::BasicCards::Estate,
      GameEngine::BasicCards::Estate,
      GameEngine::BasicCards::Duchy,
      GameEngine::BasicCards::Province,
      GameEngine::BasicCards::Province,
      GameEngine::BasicCards::Province,

      # All three basic treasures in various quantities
      GameEngine::BasicCards::Copper,
      GameEngine::BasicCards::Copper,
      GameEngine::BasicCards::Copper,
      GameEngine::BasicCards::Silver,
      GameEngine::BasicCards::Silver,
      GameEngine::BasicCards::Gold,

      # Some curses
      GameEngine::BasicCards::Curse,
      GameEngine::BasicCards::Curse,
      GameEngine::BasicCards::Curse,

      # Non-basic victories
      GameEngine::BaseGameV2::Gardens,

      # A selection of other cards
      GameEngine::BaseGameV2::Village,
      GameEngine::BaseGameV2::Village,
      GameEngine::BaseGameV2::Village,
      GameEngine::BaseGameV2::Militia,
      GameEngine::BaseGameV2::Market,
      GameEngine::BaseGameV2::Market,
      GameEngine::BaseGameV2::Workshop,
      GameEngine::BaseGameV2::Artisan,
      GameEngine::BaseGameV2::Artisan,
      GameEngine::BaseGameV2::Artisan,
      GameEngine::BaseGameV2::Bandit,
      GameEngine::BaseGameV2::Moneylender,
      GameEngine::BaseGameV2::Moat,
      GameEngine::BaseGameV2::Moat,
      GameEngine::BaseGameV2::Sentry,
    ].map { |klass| klass.new(player.game_state, pile: nil, player: player) }

    # Expect the cards sorted by score desc, then coins desc, then alphabetically
    expected_list = [
      { types: %i[victory], count: 3, name: "Province", score: 6, text: GameEngine::BasicCards::Province.card_text, last: false },
      { types: %i[victory], count: 1, name: "Duchy", score: 3, text: GameEngine::BasicCards::Duchy.card_text, last: false },
      { types: %i[victory], count: 1, name: "Gardens", score: 3, text: GameEngine::BaseGameV2::Gardens.card_text, last: false },
      { types: %i[victory], count: 2, name: "Estate", score: 1, text: GameEngine::BasicCards::Estate.card_text, last: false },
      { types: %i[curse], count: 3, name: "Curse", score: -1, text: GameEngine::BasicCards::Curse.card_text, last: false },
      { types: %i[treasure], count: 1, name: "Gold", cash: 3, text: GameEngine::BasicCards::Gold.card_text, last: false },
      { types: %i[treasure], count: 2, name: "Silver", cash: 2, text: GameEngine::BasicCards::Silver.card_text, last: false },
      { types: %i[treasure], count: 3, name: "Copper", cash: 1, text: GameEngine::BasicCards::Copper.card_text, last: false },
      { types: %i[action], count: 3, name: "Artisan", text: GameEngine::BaseGameV2::Artisan.card_text, last: false },
      { types: %i[action attack], count: 1, name: "Bandit", text: GameEngine::BaseGameV2::Bandit.card_text, last: false },
      { types: %i[action], count: 2, name: "Market", text: GameEngine::BaseGameV2::Market.card_text, last: false },
      { types: %i[action attack], count: 1, name: "Militia", text: GameEngine::BaseGameV2::Militia.card_text, last: false },
      { types: %i[action reaction], count: 2, name: "Moat", text: GameEngine::BaseGameV2::Moat.card_text, last: false },
      { types: %i[action], count: 1, name: "Moneylender", text: GameEngine::BaseGameV2::Moneylender.card_text, last: false },
      { types: %i[action], count: 1, name: "Sentry", text: GameEngine::BaseGameV2::Sentry.card_text, last: false },
      { types: %i[action], count: 3, name: "Village", text: GameEngine::BaseGameV2::Village.card_text, last: false },
      { types: %i[action], count: 1, name: "Workshop", text: GameEngine::BaseGameV2::Workshop.card_text, last: true }
    ]
    expect(player.decklist).to eq expected_list
  end
end