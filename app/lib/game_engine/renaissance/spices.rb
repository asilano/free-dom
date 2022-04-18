module GameEngine
  module Renaissance
    class Spices < Card
      text "$2",
           "+1 Buy",
           :hr,
           "When you gain this, +2 Coffers."
      treasure special: true, cash: 2
      costs 5
      on_gain do |_card, player, _from|
        player.coffers += 2
        player.game.current_journal.histories << History.new("#{player.name} got 2 Coffers (total: #{player.coffers}).",
                                                             player: player)
      end

      def play_as_treasure(played_by:)
        super

        played_by.grant_buys(1)
      end
    end
  end
end
