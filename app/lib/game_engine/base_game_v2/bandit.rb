module GameEngine
  module BaseGameV2
    class Bandit < GameEngine::Card
      text 'Action/Attack (cost: 5)',
           'Gain a Gold.',
           'Each other player reveals the top 2 cards of their deck, trashes' \
           ' a revealed Treasure other than Copper, and discards the rest.'
      action
      attack
      costs 5
    end
  end
end
