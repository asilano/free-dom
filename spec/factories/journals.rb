FactoryBot.define do
  factory :journal do
    game
    user
    sequence(:order)
    type { Journal }
    params { '' }

    factory :kingdom_journal, class: GameEngine::ChooseKingdomJournal do
      type { GameEngine::ChooseKingdomJournal }
      params do
        { card_list: %w[
          GameEngine::BaseGameV2::Artisan
          GameEngine::BaseGameV2::Bandit
          GameEngine::BaseGameV2::Bureaucrat
          GameEngine::BaseGameV2::Cellar
          GameEngine::BaseGameV2::Chapel
          GameEngine::BaseGameV2::CouncilRoom
          GameEngine::BaseGameV2::Festival
          GameEngine::BaseGameV2::Gardens
          GameEngine::BaseGameV2::Harbinger
          GameEngine::BaseGameV2::Laboratory
        ] }
      end
    end

    factory :add_player_journal, class: GameEngine::AddPlayerJournal do
      type { GameEngine::AddPlayerJournal }
    end
  end
end
