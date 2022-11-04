module GameEngine
  module Renaissance
    class Patron < Card
      text "+1 Villager",
           "+$2",
           :hr,
           "When something causes you to reveal this (using the word \"reveal\"), +1 Coffers."
      action
      reaction from: nil, to: nil # Patron _triggers_ rather than letting the player React.
      costs 4
      on_trigger(Triggers::CardRevealed) do |_card, player, _location|
        player.coffers += 1 if player
        player.game.current_journal.histories << History.new("#{player.name} gained 1 Coffers.",
          player: player)
      end

      def play(played_by:)
        played_by.villagers += 1
        played_by.grant_cash(2)
      end
    end
  end
end
