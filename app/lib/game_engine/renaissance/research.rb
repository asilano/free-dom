module GameEngine
  module Renaissance
    class Research < Card
      text "+1 Action",
           "Trash a card from your hand. Per 1 Cash it costs, set aside a card from your deck face down (on this). At the start of your next turn, put those cards into your hand."
      action
      duration
      costs 4

      def play_as_action(played_by:)
        super

        played_by.grant_actions(1)
        game_state.get_journal(TrashCardJournal, from: played_by, opts: { research: self }).process(game_state)
      end

      def tracking?
        return false unless player

        player.cards.any? { |c| c.location == :set_aside && c.location_card == self }
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: 'Choose a card to trash'

        def post_process
          # Move trashed-cost cards face down from deck to this card
          cards_to_move = player.deck_cards.take(@card_cost)
          return if cards_to_move.blank?
          cards_to_move.each do |card|
            card.move_to :set_aside
            card.location_card = opts[:research]
            opts[:research].hosting << card

            card.add_visibility_effect(self, to: player, visible: true)
            player.other_players.each do |ply|
              card.add_visibility_effect(self, to: ply, visible: false)
            end
          end

          filter = lambda do |turn_player|
            turn_player == player
          end
          Triggers::StartOfTurn.watch_for(filter: filter) do
            cards_to_move.each do |card|
              card.location = :hand
              card.location_card = nil
              opts[:research].hosting.delete card
            end
          end
        end
      end
    end
  end
end
