module GameEngine
  module Renaissance
    class Patron < Card
      text "+1 Villager",
           "+2 Cash",
           :hr,
           "When something causes you to reveal this (using the word \"reveal\"), +1 Coffers."
      action
      reaction from: :everywhere, to: :reveal
      costs 4
      on_trigger(Triggers::CardRevealed) do |_card, player, _location|
        player.coffers += 1 if player
        player.game.current_journal.histories << History.new("#{player.name} gained 1 Coffers.",
          player: player)
      end

      def play_as_action(played_by:)
        super

        played_by.villagers += 1
        played_by.grant_cash(2)
      end
    end
  end
end
