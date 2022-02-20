module GameEngine
  module Renaissance
    class SilkMerchant < Card
      text "+2 Cards",
           "+1 Buy",
           "When you gain or trash this, +1 Coffers and +1 Villager."
      action
      costs 4

      gain_trash_trigger = ->(_card, player, *_) {
        player.coffers += 1
        player.villagers += 1
        player.game.current_journal.histories << History.new("#{player.name} gained 1 Coffers.",
          player: player)
        player.game.current_journal.histories << History.new("#{player.name} gained 1 Villager.",
          player: player)
      }
      on_gain(&gain_trash_trigger)
      on_trash(&gain_trash_trigger)

      def play_as_action(played_by:)
        super

        played_by.draw_cards(2)
        played_by.grant_buys(1)
      end
    end
  end
end
