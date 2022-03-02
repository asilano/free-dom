module GameEngine
  module BaseGameV2
    class ThroneRoom < GameEngine::Card
      text 'You may play an Action card from your hand twice.'
      action
      costs 4

      attr_accessor :doubled

      def play_as_action(played_by:)
        super

        game_state.get_journal(ChooseActionJournal, from: played_by, opts: { original: self }).process(game_state)
      end

      def discard
        super

        self.doubled = nil
      end

      def tracking?
        doubled&.tracking?
      end

      class ChooseActionJournal < Journal
        define_question('Choose an Action to play twice').with_controls do |_game_state|
          [OneCardControl.new(journal_type: ChooseActionJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Double',
                              filter:       :action?,
                              null_choice:  { text: 'Choose nothing', value: 'none' },
                              css_class:    'play-action')]
        end

        validation do
          valid_hand_card(filter: ->(card) { card.action? })
        end

        process do |_game_state|
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} chose not to double anything.",
                                      player:      player,
                                      css_classes: %w[play-action])
            return
          end

          # Note the chosen card, then stop noting it when Throne Room is discarded
          card = player.hand_cards[params['choice'].to_i]
          opts[:original].doubled = card

          # Play the chosen card, then play it again
          card.play_as_action(played_by: player)
          observe
          card.play_as_action(played_by: player)
        end
      end
    end
  end
end
