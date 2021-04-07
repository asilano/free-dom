module GameEngine
  module BaseGameV2
    class Workshop < GameEngine::Card
      text 'Action (cost: 3)',
           'Gain a card costing up to 4.'
      action
      costs 3

      def play_as_action(played_by:)
        super

        game_state.get_journal(GainCardJournal, from: played_by).process(game_state)
      end

      class GainCardJournal < Journal
        define_question('Choose a card to gain').with_controls do |game_state|
          filter = ->(card) { card && card.cost <= 4 }
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
          valid_gain_by_cost(max_cost: 4)
        end

        process do |game_state|
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
