module GameEngine
  module Renaissance
    class Lackeys < Card
      text '+2 Cards',
           :hr,
           'When you gain this, +2 Villagers.'
      action
      costs 2
      on_gain do |_card, player, _from|
        player.villagers += 2
        player.game.current_journal.histories << History.new("#{player.name} got 2 Villagers (total: #{player.villagers}).",
                                                             player: player)
      end

      def play(played_by:)
        played_by.draw_cards(2)
      end
    end
  end
end
