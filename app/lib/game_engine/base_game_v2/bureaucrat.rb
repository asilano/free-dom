module GameEngine
  module BaseGameV2
    class Bureaucrat < GameEngine::Card
      text 'Action/Attack (cost: 4)',
           'Gain a Silver onto your deck.',
           'Each other player reveals a Victory card from their hand and' \
           ' puts it onto their deck (or reveals a hand with no Victory cards).'
      action
      attack
      costs 4

      def play_as_action(played_by:)
        super

        # Player gains a Silver
        Helpers.gain_card_from_supply(game_state,
                                      player:     played_by,
                                      card_class: BasicCards::Silver,
                                      to:         :deck)
        observe

        # Now, attack everyone else
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)
        if victim.hand_cards.none?(&:victory?)
          # Reveal hand (actually, because of Patron); then immediately unreveal
          victim.reveal_cards(:all, from: :hand).each do |card|
            card.be_unrevealed if card.revealed
          end
        else
          game_state.get_journal(PlaceVictoryJournal, from: victim).process(game_state)
        end
      end

      class PlaceVictoryJournal < Journal
        define_question('Choose a victory to put on your deck').with_controls do |_game_state|
          [OneCardControl.new(journal_type: PlaceVictoryJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         'Place',
                              filter:       :victory?,
                              css_class:    'place-card')]
        end

        validation do
          return false unless journal.params['choice']&.integer?

          choice = journal.params['choice'].to_i
          choice < journal.player.hand_cards.length &&
            journal.player.hand_cards[choice].victory?
        end

        process do |_game_state|
          # Place the chosen card on its owner's deck
          card = player.hand_cards[params['choice'].to_i]
          @histories << History.new("#{player.name} placed #{card.readable_name} from their hand onto their deck.",
                                    player:      player,
                                    css_classes: %w[place-card])
          card.put_on_deck(player, from: player.cards)
          observe
        end
      end
    end
  end
end
