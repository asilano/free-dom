module GameEngine
  module BaseGameV2
    class Moneylender < GameEngine::Card
      text 'Action (cost: 4)',
           'You may trash a Copper from your hand for +3 Cash.'
      action
      costs 4
    end
  end
end