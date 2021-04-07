module GameEngine
  module BaseGameV2
    class Mine < GameEngine::Card
      text 'Action (cost: 5)',
           'You may trash a Treasure from your hand. Gain a Treasure to your hand' \
           ' costing up to 3 more than it.'
      action
      costs 5

      def play_as_action(played_by:)
        super

        game_state.get_journal(TrashTreasureJournal, from: played_by).process(game_state)
      end

      class TrashTreasureJournal < Journal
        define_question('Choose a Treasure to trash').with_controls do |_game_state|
          [OneCardControl.new(journal_type: TrashTreasureJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Trash',
                              filter:       :treasure?,
                              null_choice:  { text: 'Trash nothing', value: 'none' },
                              css_class:    'trash-card')]
        end

        validation do
          return true if journal.params['choice'] == 'none'
          return false unless journal.params['choice']&.integer?

          choice = journal.params['choice'].to_i
          choice < journal.player.hand_cards.length &&
            journal.player.hand_cards[choice].treasure?
        end

        process do |_game_state|
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} trashed nothing.",
                                      player:      player,
                                      css_classes: %w[trash-card])
            return
          end

          # Trash the chosen card
          card = player.hand_cards[params['choice'].to_i]
          card_cost = card.cost
          @histories << History.new("#{player.name} trashed #{card.readable_name} from their hand.",
                                    player:      player,
                                    css_classes: %w[trash-card])
          card.trash(from: player.cards)
          observe

          # Ask the player to take a replacement
          game_state.get_journal(GainTreasureJournal, from: player, opts: { trashed_cost: card_cost }).process(game_state)
        end
      end

      class GainTreasureJournal < Journal
        define_question('Choose a Treasure to gain to hand').with_controls do |game_state|
          filter = ->(card) { card && card.treasure? && card.cost <= opts[:trashed_cost] + 3 }
          [OneCardControl.new(journal_type: GainTreasureJournal,
                              question:     self,
                              player:       @player,
                              scope:        :supply,
                              text:         'Gain',
                              filter:       filter,
                              null_choice:  if game_state.piles.map(&:cards).map(&:first).none?(&filter)
                                              { text: 'Gain nothing', value: 'none' }
                                            end,
                              css_class:    'gain-card')]
        end

        validation do
          valid_gain_choice(filter: ->(card) { card && card.treasure? && card.cost <= opts[:trashed_cost] + 3 })
        end

        process do |_game_state|
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} gained nothing.",
                                      player: player,
                                      css_classes: %w[gain-card])
            return
          end

          pile = game_state.piles[params['choice'].to_i]
          card = pile.cards.first

          @histories << History.new("#{player.name} gained #{card.readable_name} to their hand.",
                                    player: player,
                                    css_classes: %w[gain-card])
          card.be_gained_by(player, from: pile.cards, to: :hand)
          observe
        end
      end
    end
  end
end