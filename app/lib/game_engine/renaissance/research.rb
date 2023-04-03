module GameEngine
  module Renaissance
    class Research < Card
      text "+1 Action",
           "Trash a card from your hand. Per $1 it costs, set aside a card from your deck face down (on this). " \
           "At the start of your next turn, put those cards into your hand."
      action
      duration
      costs 4

      def play(played_by:)
        played_by.grant_actions(1)
        game_state.get_journal(TrashCardJournal, from: played_by, opts: { research: self }).process(game_state)
      end

      def tracking?
        return false unless player

        player.cards.any? { |c| c.location == :set_aside && c.location_card == self }
      end

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: "Choose a card to trash"

        def post_process
          # Move trashed-cost cards face down from deck to this card
          cards_to_move = player.deck_cards.take(@card_cost)
          if cards_to_move.blank?
            @histories << History.new("#{player.name} set nothing aside on #{Research.readable_name}.")
            return
          end

          game.fix_journal

          log = "#{player.name} set aside " +
            History.personal_log(private_to: player.user,
                                 private_msg: cards_to_move.map(&:readable_name).join(", "),
                                 public_msg: "#{cards_to_move.length} #{"card".pluralize(cards_to_move.length)}") +
            " on #{Research.readable_name}."
          @histories << History.new(log, player:)

          cards_to_move.each do |card|
            card.set_aside on: opts[:research]

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
              card.return_from_set_aside to: :hand
            end
          end
        end
      end
    end
  end
end
