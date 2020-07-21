module GameEngine
  module BaseGameV2
    class Library < GameEngine::Card
      text 'Action (cost: 5)',
           'Draw until you have 7 cards in hand, skipping any Action' \
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
            game_state.get_journal(SetAsideJournal, from: played_by, opts: { card: drawn.first}).process(game_state)
          end
        end
      end

      class SetAsideJournal < Journal
        define_question('Set aside or keep action').with_controls do |game_state|
          [OneCardControl.new(journal_type: SetAsideJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Set aside',
                              filter:       ->(card) { card == @opts[:card] },
                              null_choice:  { text: 'Keep', value: 'keep' })]
        end

        validation do
          return false unless journal.params['choice']&.integer?

          journal.player.hand_cards[journal.params['choice'].to_i] == opts[:card]
        end
      end
    end
  end
end