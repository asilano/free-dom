module GameEngine
  module Renaissance
    class Treasurer < Card
      text "+$3",
           "Choose one: Trash a Treasure from your hand;" +
           " or gain a Treasure from the trash to your hand;" +
           " or take the Key."
      action
      costs 5

      setup do |game_state|
        game_state.create_artifact(CardShapedThings::Artifacts::Key)
      end

      def play_as_action(played_by:)
        super

        played_by.grant_cash(3)
        game_state.get_journal(ChooseModeJournal, from: played_by).process(game_state)
      end

      class ChooseModeJournal < Journal
        define_question("Choose mode for Treasurer").with_controls do |_|
          [ButtonControl.new(journal_type: ChooseModeJournal,
                             question:     self,
                             player:       @player,
                             scope:        :player,
                             values:       [["Trash a Treasure", "trash"],
                                            ["Gain a Treasure", "gain"],
                                            ["Take the Key", "key"]])]
        end

        validation do
          %w[trash gain key].include? params["choice"]
        end

        process do |game_state|
          case params["choice"]
          when "trash"
            @histories << History.new("#{player.name} chose to trash a treasure with #{Treasurer.readable_name}.")
            game_state.get_journal(TrashTreasureJournal, from: player).process(game_state)
          when "gain"
            @histories << History.new("#{player.name} chose to gain a treasure from trash with #{Treasurer.readable_name}.")
            game_state.get_journal(GainTreasureJournal, from: player).process(game_state)
          when "key"
            @histories << History.new("#{player.name} chose to gain a gain the Key from #{Treasurer.readable_name}.")
            game_state.artifacts["Key"].give_to(player)
          end
        end
      end

      class TrashTreasureJournal < CommonJournals::TrashJournal
        configure question_text: "Choose a Treasure to trash",
                  filter:        :treasure?
      end

      class GainTreasureJournal < CommonJournals::GainJournal
        configure question_text: "Choose a Treasure to gain from trash",
                  filter:        :treasure?,
                  source:        :trash

        validation do
          valid_gain_choice(filter: ->(card) { !card || card.treasure? },
                            source: game_state.trashed_cards,
                            pile:   false)
        end
      end
    end
  end
end
