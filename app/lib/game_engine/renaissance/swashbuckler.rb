module GameEngine
  module Renaissance
    class Swashbuckler < Card
      text "+3 Cards",
           "If your discard pile has any cards in it:",
           "+1 Coffers, then if you have at least 4 Coffers tokens, take the Treasure Chest."
      action
      costs 5

      setup do |game_state|
        game_state.create_artifact(CardShapedThings::Artifacts::TreasureChest)
      end

      def play(played_by:)
        played_by.draw_cards(3)
        return if played_by.discarded_cards.empty?

        played_by.coffers += 1
        return unless played_by.coffers >= 4

        game_state.artifacts["TreasureChest"].give_to(played_by)
        game.current_journal.histories << History.new("#{played_by.name} took the Treasure Chest.",
                                                      player: played_by)

      end
    end
  end
end
