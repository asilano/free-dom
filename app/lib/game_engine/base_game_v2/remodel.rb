module GameEngine
  module BaseGameV2
    class Remodel < GameEngine::Card
      text 'Action (cost: 4)',
           'Trash a card from your hand. Gain a card costing up to 2 more than it.'
      action
      costs 4

      def play_as_action(played_by:)
        super

        game_state.get_journal(TrashCardJournal, from: played_by).process(game_state)
      end

      class TrashCardJournal < Journal
        define_question('Choose a card to trash').with_controls do |_game_state|
          [OneCardControl.new(journal_type: TrashCardJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Trash',
                              null_choice:  if @player.hand_cards.empty?
                                              { text: 'Trash nothing', value: 'none' }
                                            end,
                              css_class:    'trash-card')]
        end

        validation do
          return false if journal.params['choice'] == 'none' && @player.hand_cards.present?
          return true if journal.params['choice'] == 'none'
          return false unless journal.params['choice']&.integer?

          journal.params['choice'].to_i < journal.player.hand_cards.length
        end

        process do |_game_state|
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} trashed nothing.",
                                      player:      player,
                                      css_classes: %w[trash-card])
            return
          end

          # Trash the chosen card on its owner's deck
          card = player.hand_cards[params['choice'].to_i]
          card_cost = card.cost
          @histories << History.new("#{player.name} trashed #{card.readable_name} from their hand.",
                                    player:      player,
                                    css_classes: %w[trash-card])
          card.trash(from: player.cards)
          observe

          # Ask the player to take a replacement
          game_state.get_journal(GainCardJournal, from: player, opts: { trashed_cost: card_cost }).process(game_state)
        end
      end

      class GainCardJournal < Journal
        define_question('Choose a card to gain').with_controls do |game_state|
          filter = ->(card) { card && card.cost <= opts[:trashed_cost] + 2 }
          [OneCardControl.new(journal_type: GainCardJournal,
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
          filter = ->(card) { card && card.cost <= opts[:trashed_cost] + 3 }
          no_choices = journal.game_state.piles.map(&:cards).map(&:first).none?(&filter)
          return true if no_choices && journal.params['choice'] == 'none'
          return false if !no_choices && journal.params['choice'] == 'none'
          return false unless journal.params['choice']&.integer?

          choice = journal.params['choice'].to_i
          choice < journal.game_state.piles.length && filter[journal.game_state.piles[choice].cards.first]
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
          card.be_gained_by(player, from: pile.cards)
          observe
        end
      end
    end
  end
end