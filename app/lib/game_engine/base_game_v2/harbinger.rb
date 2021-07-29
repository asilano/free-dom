module GameEngine
  module BaseGameV2
    class Harbinger < GameEngine::Card
      text 'Action (cost: 3)',
           '+1 Card',
           '+1 Action',
           'Look through your discard pile. You may put a card from it onto your deck.'
      action
      costs 3

      def play_as_action(played_by:)
        super

        played_by.draw_cards(1)
        observe
        played_by.grant_actions(1)
        game_state.get_journal(ReturnCardJournal, from: played_by).process(game_state)
      end

      class ReturnCardJournal < Journal
        define_question('Choose a card to return from your discard').with_controls do |_game_state|
          [OneCardControl.new(journal_type: ReturnCardJournal,
                              question:     self,
                              player:       @player,
                              scope:        :discard,
                              text:         'Return',
                              null_choice:  { text: 'Return nothing', value: 'none' })]
        end

        validation do
          return true if params['choice'] == 'none'
          return false unless params['choice']&.integer?

          choice = params['choice'].to_i
          choice < player.discarded_cards.length
        end

        process do |_game_state|
          # Just log if the player chose nothing
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} returned nothing",
                                      player:      player)
            return
          end

          card = player.discarded_cards[params['choice'].to_i]

          @histories << History.new("#{player.name} returned #{card.readable_name} from their discard to their deck.",
                                    player: player)
          card.put_on_deck(player, from: player.cards)
        end
      end
    end
  end
end
