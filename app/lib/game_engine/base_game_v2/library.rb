module GameEngine
  module BaseGameV2
    class Library < GameEngine::Card
      text 'Action (cost: 5)',
           'Draw until you have 7 cards in hand, skipping any Action' \
           ' cards you choose to; set those aside, discarding them afterwards.'
      action
      costs 5
    end
  end
end