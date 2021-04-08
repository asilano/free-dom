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

      class TrashCardJournal < CommonJournals::TrashJournal
        configure question_text: 'Choose a card to trash'

        def post_process
          # Ask the player to take a replacement
          game_state.get_journal(GainCardJournal, from: player, opts: { trashed_cost: @card_cost }).process(game_state)
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
          valid_gain_choice(filter: ->(card) { card && card.cost <= opts[:trashed_cost] + 3 })
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

          @histories << History.new("#{player.name} gained #{card.readable_name}.",
                                    player: player,
                                    css_classes: %w[gain-card])
          card.be_gained_by(player, from: pile.cards)
          observe
        end
      end
    end
  end
end