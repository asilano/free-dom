module GameEngine
  module BaseGameV2
    class Gardens < GameEngine::Card
      victory do |card|
        card.player.cards.count / 10
      end
      costs 4
    end
  end
end