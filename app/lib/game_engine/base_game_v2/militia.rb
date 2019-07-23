module GameEngine
  module BaseGameV2
    class Militia < GameEngine::Card
      text 'Action/Attack (cost: 4)',
           '+2 Cash',
           'Each other player discards down to 3 cards in hand.'
      action
      attack
      costs 4
    end
  end
end