# Once per turn, when you discard a Border Guard from play, you may put it onto your deck.
module GameEngine
  module CardShapedThings
    module Artifacts
      class Horn < Artifact
        comes_from Renaissance::BorderGuard
        text "Once per turn, when you discard a Border Guard from play, you may put it onto your deck."

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do
            filter = lambda do |card, player, from|
              card.is_a?(Renaissance::BorderGuard) &&
                player == @owner &&
                from == :play
            end
            Triggers::CardDiscarded.watch_for(filter:   filter,
                                              whenever: true,
                                              stop_at:  :end_of_turn) do |card, player, _from|
              used = @game_state.get_journal(PlaceBorderGuardJournal, from: player,
                                                                      opts: { border_guard: card }).process(@game_state)
              :unwatch if used
            end
          end
        end

        class PlaceBorderGuardJournal < Journal
          define_question('Place Border Guard on your deck?').with_controls do |_game_state|
            [OneCardControl.new(journal_type: journal_type,
                                question:     self,
                                player:       @player,
                                scope:        :discard,
                                filter:       ->(card) { card == opts[:border_guard] },
                                text:         'Return',
                                null_choice:  { text: 'Leave in discard', value: 'none' })]
          end

          validation do
            return true if params['choice'] == 'none'
            return false unless params['choice']&.integer?

            choice = params['choice'].to_i
            player.discarded_cards[choice] == opts[:border_guard]
          end

          process do |_game_state|
            # Just log if the player chose nothing
            if params['choice'] == 'none'
              @histories << History.new("#{player.name} chose not to return a specific Border Guard",
                                        player:      player)
              return false
            end

            card = player.discarded_cards[params['choice'].to_i]

            @histories << History.new("#{player.name} returned #{card.readable_name} from their discard to their deck.",
                                      player: player)
            card.put_on_deck(player, from: player.cards)
            return true
          end
        end
      end
    end
  end
end
