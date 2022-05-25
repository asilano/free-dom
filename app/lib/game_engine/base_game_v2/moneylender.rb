module GameEngine
  module BaseGameV2
    class Moneylender < GameEngine::Card
      text "You may trash a Copper from your hand for +$3."
      action
      costs 4

      def play(played_by:)
        game_state.get_journal(TrashCopperJournal, from: played_by).process(game_state)
      end

      class TrashCopperJournal < Journal
        define_question('Choose whether to trash a Copper').with_controls do |game_state|
          opts = [["Don't trash", 'none']]
          opts.prepend(['Trash', 'trash']) if @player.hand_cards.any? { |c| c.is_a? BasicCards::Copper }
          [ButtonControl.new(journal_type: TrashCopperJournal,
                             question:     self,
                             player:       @player,
                             scope:        :player,
                             values:       opts)]
        end

        validation do
          %w[none trash].include? params['choice']
        end

        process do |_game_state|
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} chose not to trash a Copper.",
                                      player: player,
                                      css_classes: %w[trash-card])
            return
          end

          player.hand_cards.detect { |c| c.is_a? BasicCards::Copper }.trash(from: player.cards)
          player.cash += 3

          @histories << History.new("#{player.name} trashed a Copper for 3 cash.",
                                    player: player,
                                    css_classes: %w[trash-card])
        end
      end
    end
  end
end
