module GameEngine
  module Renaissance
    class MountainVillage < Card
      text "+2 Actions",
           "Look through your discard pile and put a card from it into your hand; if you can't, +1 Card."
      action
      costs 4

      def play(played_by:)
        played_by.grant_actions(2)
        game_state.get_journal(ReturnCardJournal, from: played_by).process(game_state)
      end

      class ReturnCardJournal < Journal
        define_question('Choose a card to return from your discard').with_controls do |_game_state|
          [OneCardControl.new(journal_type: ReturnCardJournal,
                              question:     self,
                              player:       @player,
                              scope:        :discard,
                              text:         'Return',
                              null_choice:  if @player.discarded_cards.blank?
                                              { text: 'Return nothing', value: 'none' }
                                            end)]
        end

        validation do
          return true if params['choice'] == 'none' && player.discarded_cards.blank?
          return false if params['choice'] == 'none' && player.discarded_cards.present?
          return false unless params['choice']&.integer?

          choice = params['choice'].to_i
          choice < player.discarded_cards.length
        end

        process do |_game_state|
          # If the player chose nothing, they draw a card
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} returned nothing",
                                      player: player)
            player.draw_cards(1)
            return
          end

          card = player.discarded_cards[params['choice'].to_i]

          @histories << History.new("#{player.name} returned #{card.readable_name} from their discard to their hand.",
                                    player: player)
          card.move_to_hand
        end
      end
    end
  end
end
