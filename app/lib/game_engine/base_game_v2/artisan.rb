module GameEngine
  module BaseGameV2
    class Artisan < GameEngine::Card
      text 'Action (cost: 6)',
           'Gain a card to your hand costing up to 5. Put a card from your hand onto your deck.'
      action
      costs 6
    end
  end
end