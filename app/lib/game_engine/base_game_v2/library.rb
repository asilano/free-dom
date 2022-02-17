module GameEngine
  module BaseGameV2
    class Library < GameEngine::Card
      text 'Draw until you have 7 cards in hand, skipping any Action' \
           ' cards you choose to; set those aside, discarding them afterwards.'
      action
      costs 5

      def play_as_action(played_by:)
        super

        until played_by.hand_cards.length >= 7
          drawn = played_by.draw_cards(1)
          observe

          break if drawn.blank?

          if drawn.first.action?
            game_state.get_journal(SetAsideJournal, from: played_by, opts: { card: drawn.first }).process(game_state)
          end
        end

        # Discard any set-aside cards
        if (set_aside = played_by.cards_by_location(:library)).any?
          game.current_journal.histories << History.new("#{played_by.name} discarded #{set_aside.map(&:readable_name).join(', ')}.",
                                                         player: played_by,
                                                         css_classes: %w[discard])
          set_aside.each(&:discard)
        end
      end

      class SetAsideJournal < Journal
        define_question('Set aside or keep action').with_controls do |_game_state|
          [OneCardControl.new(journal_type: SetAsideJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Set aside',
                              filter:       ->(card) { card == opts[:card] },
                              null_choice:  { text: 'Keep', value: 'keep' })]
        end

        validation do
          return true if params['choice'] == 'keep'
          return false unless params['choice']&.integer?

          player.hand_cards[params['choice'].to_i] == opts[:card]
        end

        process do |_game_state|
          # Do nothing if the player chose to keep - it should be totally secret
          # but create a private history for the player.
          if params['choice'] == 'keep'
            @histories << History.new_secret("#{player.name} chose to keep #{opts[:card].readable_name}.",
                                             player: player)
            return
          end

          card = player.hand_cards[params['choice'].to_i]
          @histories << History.new("#{player.name} chose to set aside #{card.readable_name}.",
                                    player: player)
          card.move_to(:library)
        end
      end
    end
  end
end