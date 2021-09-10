module GameEngine
  module Renaissance
    class Lackeys < Card
      text 'Action (cost: 2)',
           '+2 Cards',
           'When you gain this, +2 Villagers.'
      action
      costs 2

      def play_as_action(played_by:)
        super

        played_by.draw_cards(2)
      end
    end
  end
end
