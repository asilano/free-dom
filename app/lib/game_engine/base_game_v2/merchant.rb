module GameEngine
  module BaseGameV2
    class Merchant < GameEngine::Card
      text '+1 Card',
           '+1 Action',
           'The first time you play a Silver this turn, +1 Cash.'
      action
      costs 3

      def play(played_by:)
        played_by.draw_cards(1)
        observe
        played_by.grant_actions(1)

        my_silver_filter = ->(card, player) { card.is_a?(BasicCards::Silver) && player == played_by }
        Triggers::TreasurePlayed.watch_for(filter: my_silver_filter, stop_at: :end_of_turn) do
          played_by.cash += 1
          game.current_journal.histories << History.new("#{played_by} gained 1 cash due to Merchant (total: $#{played_by.cash}).",
                                                        player: played_by)
        end
      end
    end
  end
end
