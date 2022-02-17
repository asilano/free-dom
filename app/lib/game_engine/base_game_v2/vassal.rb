module GameEngine
  module BaseGameV2
    class Vassal < GameEngine::Card
      text '+2 Cash',
           'Discard the top card of your deck. If it\'s an Action card, you may play it.'
      action
      costs 3

      def play_as_action(played_by:)
        super

        played_by.cash += 2
        disc_card = played_by.discard_cards(1, from: :deck)[0]

        if disc_card&.action?
          game_state.get_journal(PlayDiscardJournal,
                                 from: played_by,
                                 opts: { discarded: disc_card }).process(game_state)
        end
      end

      class PlayDiscardJournal < Journal
        define_question { |_| "Choose to play #{opts[:discarded].readable_name}" }
          .with_controls do |_game_state|
            [ButtonControl.new(journal_type: PlayDiscardJournal,
                               question:     self,
                               player:       @player,
                               scope:        :player,
                               values:       [["Play #{opts[:discarded].readable_name}", 'play'],
                                              ["Don't play", 'decline']])]
          end

        validation do
          %w[play decline].include? params['choice']
        end

        process do |_game_state|
          if params['choice'] == 'decline'
            @histories << History.new("#{player.name} chose not to play #{opts[:discarded].readable_name}.",
                                      player:      player,
                                      css_classes: %w[play-action])
            return
          end

          opts[:discarded].play_as_action(played_by: player)
        end
      end
    end
  end
end