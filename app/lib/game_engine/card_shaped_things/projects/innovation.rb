module GameEngine
  module CardShapedThings
    module Projects
      class Innovation < Project
        text "The first time you gain an Action card during each of your turns, you may play it."
        costs 6

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            filter = ->(card, *) { card.action? }
            Triggers::CardGained.watch_for(filter: filter, stop_at: :end_of_turn) do |card, gainer|
              next unless owners.include?(gainer) && gainer == turn_player

              game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{gainer.name}.",
                player: gainer)
              game_state.get_journal(PlayOnGainJournal, from: gainer, opts: { card: card }).process(game_state)
            end
          end
        end

        class PlayOnGainJournal < Journal
          define_question { |_| "Choose whether to play #{opts[:card].readable_name}" }
              .with_controls do |game_state|
            [ButtonControl.new(journal_type: PlayOnGainJournal,
                               question:     self,
                               player:       @player,
                               scope:        :player,
                               values:       [["Play #{opts[:card].readable_name}", "play"],
                                              ["Don't play #{opts[:card].readable_name}", "none"]])]
          end

          validation do
            %w[none play].include? params['choice']
          end

          process do |_game_state|
            if params['choice'] == 'none'
              @histories << History.new("#{player.name} chose not to play #{opts[:card]}.",
                                        player:      player,
                                        css_classes: %w[play-action])
              return
            end

            opts[:card].play_card(played_by: player)
          end
        end
      end
    end
  end
end
