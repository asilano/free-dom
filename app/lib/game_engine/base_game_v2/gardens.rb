module GameEngine
  module BaseGameV2
    class Gardens < GameEngine::Card
      text 'Worth 1 point per 10 cards you have (round down).'
      victory do |card|
        card.player.cards.count / 10
      end
      costs 4
    end
  end
end
