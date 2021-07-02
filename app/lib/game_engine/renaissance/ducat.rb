module GameEngine
  module Renaissance
    class Ducat < Card
      text 'Treasure (cost: 2)',
           '+1 Coffers',
           '+1 Buy',
           'When you gain this, you may trash a Copper from your hand.'
      treasure special: true
      costs 2

      def play_as_treasure(played_by:)
        super(played_by: played_by, stop_before_cash: true)

        played_by.coffers += 1
        played_by.buys += 1
        game.current_journal.histories << GameEngine::History.new("#{played_by.name} played #{readable_name} (total: $#{played_by.cash}).",
                                                                  player:      played_by,
                                                                  css_classes: types + %w[play-treasure])
      end
    end
  end
end
