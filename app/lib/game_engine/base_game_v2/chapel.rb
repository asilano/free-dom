module GameEngine
  module BaseGameV2
    class Chapel < GameEngine::Card
      text 'Action (cost: 2)',
           'Trash up to 4 cards from your hand.'
      action
      costs 2
    end
  end
end
