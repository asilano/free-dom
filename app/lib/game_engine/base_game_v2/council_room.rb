module GameEngine
  module BaseGameV2
    class CouncilRoom < GameEngine::Card
      text 'Action (cost: 5)',
           '+1 Buy',
           'Each other player draws a card.'
      action
      costs 5
    end
  end
end
