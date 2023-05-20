module GameEngine
  module Cornucopia
    class Remake < Card
      text "Do this twice: Trash a card from your hand, then gain a card costing exactly $1 more than it."
      action
      costs 4

      def play(played_by:)
        2.times do |time|
          game_state.get_journal(TrashCardJournal, from: played_by, opts: {time: time + 1}).process(game_state)
        end
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_block: ->(_) { "Choose #{opts[:time].ordinalize} card to trash" }

        def post_process
          # Ask the player to take a replacement
          game_state.get_journal(GainCardJournal, from: player, opts: { trashed_cost: @card_cost }).process(game_state)
        end
      end

      class GainCardJournal < CommonJournals::GainJournal
        configure question_text: "Choose a card to gain",
                  filter:        ->(card) { card && card.cost == opts[:trashed_cost] + 1 }

        validation do
          valid_gain_choice(filter: ->(card) { card && card.cost == opts[:trashed_cost] + 1 })
        end
      end

    end
  end
end
