module GameEngine
  module BaseGameV2
    class Militia < GameEngine::Card
      text '+2 Cash',
           'Each other player discards down to 3 cards in hand.'
      action
      attack
      costs 4

      def play_as_action(played_by:)
        super

        played_by.grant_cash(2)

        # Now, attack everyone else
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)
        # Skip players with too-small hands (can do so silently)
        until victim.hand_cards.length <= 3
          game_state.get_journal(DiscardJournal, from: victim).process(game_state)
        end
      end

      class DiscardJournal < Journal
        define_question { |_| "Discard down by #{pluralize(@player.hand_cards.length - 3, 'card')}" }.with_controls do |_game_state|
          [OneCardControl.new(journal_type: DiscardJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Discard',
                              css_class:    'discard-card')]
        end

        validation do
          return false unless params['choice']&.integer?

          choice = params['choice'].to_i
          choice < player.hand_cards.length
        end

        process do |_game_state|
          # Have the player discard the chosen card
          card = player.hand_cards[params['choice'].to_i]
          @histories << History.new("#{player.name} discarded #{card.readable_name}.",
                                    player:      player,
                                    css_classes: %w[discard-card])
          card.discard
          observe
        end
      end
    end
  end
end
