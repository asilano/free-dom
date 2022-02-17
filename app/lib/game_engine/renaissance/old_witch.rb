module GameEngine
  module Renaissance
    class OldWitch < Card
      text "+3 Cards",
           "Each other player gains a Curse and may trash a Curse from their hand."
      action
      attack
      costs 5

      def play_as_action(played_by:)
        super

        played_by.draw_cards(3)

        # Now, attack everyone else
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)
        # Victim gains a Curse
        Helpers.gain_card_from_supply(game_state,
          player:     victim,
          card_class: BasicCards::Curse)

        # And now, let them trash one
        game_state.get_journal(TrashCurseJournal, from: victim).process(game_state)
      end

      class TrashCurseJournal < Journal
        define_question('Choose whether to trash a Curse').with_controls do |game_state|
          opts = [["Don't trash", 'none']]
          opts.prepend(['Trash', 'trash']) if @player.hand_cards.any? { |c| c.is_a? BasicCards::Curse }
          [ButtonControl.new(journal_type: TrashCurseJournal,
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
            @histories << History.new("#{player.name} chose not to trash a Curse.",
                                      player: player,
                                      css_classes: %w[trash-card])
            return
          end

          player.hand_cards.detect { |c| c.is_a? BasicCards::Curse }.trash(from: player.cards)

          @histories << History.new("#{player.name} trashed a Curse.",
                                    player: player,
                                    css_classes: %w[trash-card])
        end
      end
    end
  end
end
