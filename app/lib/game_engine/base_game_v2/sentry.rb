module GameEngine
  module BaseGameV2
    class Sentry < GameEngine::Card
      text 'Action (cost: 5)',
           '+1 Card',
           '+1 Action',
           'Look at the top 2 cards of your deck. Trash and/or discard any number of them.' \
           ' Put the rest back in any order.'
      action
      costs 5

      def play_as_action(played_by:)
        super

        played_by.draw_cards(1)
        observe
        played_by.grant_actions(1)

        if played_by.deck_cards.empty?
          game_state.histories << History.new("#{played_by.name} has no cards in their deck.",
                                              player:      played_by,
                                              css_classes: %w[peek-cards])
        else
          game_state.get_journal(ScryJournal, from: played_by).process(game_state)
        end
      end

      class ScryJournal < Journal
        define_question('Trash and/or discard cards on your deck').with_controls do |game_state|
          [MultiCardChoicesControl.new(journal_type: ScryCardsJournal,
                                       question:     self,
                                       player:       @player,
                                       scope:        :deck,
                                       filter:       ->(card) { @player.deck_cards[0..2].include?(card) },
                                       choices:      {
                                         'Discard' => 'discard',
                                         'Trash'   => 'trash',
                                         'Keep'    => 'keep'
                                       },
                                       submit_text:  'Submit',
                                       css_class:    'scry')]
        end
      end
    end
  end
end
