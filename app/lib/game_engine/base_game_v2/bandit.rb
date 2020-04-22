module GameEngine
  module BaseGameV2
    class Bandit < GameEngine::Card
      text 'Action/Attack (cost: 5)',
           'Gain a Gold.',
           'Each other player reveals the top 2 cards of their deck, trashes' \
           ' a revealed Treasure other than Copper, and discards the rest.'
      action
      attack
      costs 5

      def play_as_action(played_by:)
        super

        # Player gains a Gold
        Helpers.gain_card_from_supply(game_state, player: played_by, card_class: BasicCards::Gold)

        # Now, attack everyone else
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)
        victim.reveal_cards(2, from: :deck)
        game_state.get_journal(TrashTreasureJournal, from: victim).process(game_state)
      end

      class TrashTreasureJournal < Journal
        define_question('Choose a treasure to trash').with_controls do |_game_state|
          filter = ->(card) { card && card.revealed? && card.treasure? && !card.is_a?(GameEngine::BasicCards::Copper) }
          [OneCardControl.new(journal_type: TrashTreasureJournal,
                              player: @player,
                              scope: :deck,
                              text: 'Trash',
                              filter: filter,
                              null_choice: if @player.deck_cards.none?(&filter)
                                             { text: 'Trash nothing', value: 'none' }
                                           end,
                              css_class: 'trash-card')]
        end

        validation do
          return true if player.deck_cards.select(&:revealed?).empty? && journal.params['choice'] == 'none'
          return true if player.deck_cards.select(&:revealed?).none? { |c| c.treasure? && !c.is_a?(GameEngine::BasicCards::Copper) }
          return false if player.deck_cards.select(&:revealed?).present? && journal.params['choice'] == 'none'
          return false unless journal.params['choice'].integer?

          choice = journal.params['choice'].to_i
          choice < journal.player.deck_cards.select(&:revealed?).length &&
            journal.player.deck_cards.select(&:revealed?)[choice].treasure?
        end

        process do |_game_state|
          # Done looking at cards. Trash up to one, and discard the rest!
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} trashed nothing.",
                                      player: player,
                                      css_classes: %w[trash-card])
          else
            # Trash the card.
            card = player.deck_cards.select(&:revealed?)[params['choice'].to_i]
            @histories << History.new("#{player.name} trashed #{card.readable_name} from their deck.",
                                      player: player,
                                      css_classes: %w[trash-card])
            card.trash(from: player.cards)
          end

          # Discard any remaining revealed cards.
          return if player.deck_cards.select(&:revealed?).empty?

          @histories << History.new("#{player.name} discarded #{player.deck_cards.select(&:revealed?).map(&:readable_name).join(', ')} from their deck.",
                                    player: player,
                                    css_classes: %w[discard-card])
          player.deck_cards.select(&:revealed?).each(&:discard)
        end
      end
    end
  end
end
