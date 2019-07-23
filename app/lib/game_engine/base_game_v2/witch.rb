module GameEngine
  module BaseGameV2
    class Witch < GameEngine::Card
      text 'Action/Attack (cost: 5)',
           '+2 Cards',
           'Each other player gains a Curse.'
      action
      attack
      costs 5
    end
  end
end