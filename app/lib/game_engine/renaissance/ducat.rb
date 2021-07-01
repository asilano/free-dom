module GameEngine
  module Renaissance
    class Ducat < Card
      text 'Treasure (cost: 2)',
           '+1 Coffers',
           '+1 Buy',
           'When you gain this, you may trash a Copper from your hand.'
      action
      costs 2
    end
  end
end
