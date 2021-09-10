module GameEngine
  module Renaissance
    class Ducat < Card
      text 'Treasure (cost: 2)',
           '+1 Coffers',
           '+1 Buy',
           'When you gain this, you may trash a Copper from your hand.'
      treasure special: true
      costs 2
      on_gain do |card, player, _from|
        card.game_state.get_journal(TrashCopperJournal, from: player).process(card.game_state)
      end

      def play_as_treasure(played_by:)
        super(played_by: played_by, stop_before_cash: true)

        played_by.coffers += 1
        played_by.buys += 1
        game.current_journal.histories << GameEngine::History.new("#{played_by.name} played #{readable_name} (total: $#{played_by.cash}).",
                                                                  player:      played_by,
                                                                  css_classes: types + %w[play-treasure])
      end

      class TrashCopperJournal < Journal
        define_question('Choose whether to trash a Copper').with_controls do |_game_state|
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
                                      player:      player,
                                      css_classes: %w[trash-card])
            return
          end

          player.hand_cards.detect { |c| c.is_a? BasicCards::Copper }.trash(from: player.cards)

          @histories << History.new("#{player.name} trashed a Copper.",
                                    player:      player,
                                    css_classes: %w[trash-card])
        end
      end
    end
  end
end
