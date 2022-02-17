module GameEngine
  module BaseGameV2
    class Artisan < GameEngine::Card
      text 'Gain a card to your hand costing up to 5. Put a card from your hand onto your deck.'
      action
      costs 6

      def play_as_action(played_by:)
        super

        game_state.get_journal(GainCardJournal, from: played_by).process(game_state)
      end

      class GainCardJournal < CommonJournals::GainJournal
        configure question_text: 'Choose a card to gain into your hand',
                  filter:        ->(card) { card && card.cost <= 5 },
                  destination:   :hand

        validation do
          valid_gain_by_cost(max_cost: 5)
        end

        def post_process
          game_state.get_journal(PlaceCardJournal, from: player).process(game_state)
        end
      end

      class PlaceCardJournal < Journal
        define_question('Choose a card to put onto your deck').with_controls do |_game_state|
          [OneCardControl.new(journal_type: PlaceCardJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Put on deck',
                              null_choice:  if @player.hand_cards.blank?
                                              { text:  'Put nothing on deck',
                                                value: 'none' }
                                            end)]
        end

        validation do
          return true if player.hand_cards.empty? && params['choice'] == 'none'
          return false if player.hand_cards.present? && params['choice'] == 'none'
          return false unless params['choice']&.integer?

          choice = params['choice'].to_i
          choice < player.hand_cards.length
        end

        process do |_game_state|
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} placed nothing on their deck.",
                                      player: player)
            return
          end

          # Retrieve the card and put it on the player's deck
          card = player.hand_cards[params['choice'].to_i]
          @histories << History.new("#{player.name} put #{card.readable_name} onto their deck.",
                                    player: player)
          card.put_on_deck(player, from: player.cards)
          observe
        end
      end
    end
  end
end
