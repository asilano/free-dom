module GameEngine
  module BaseGameV2
    class Artisan < GameEngine::Card
      text 'Action (cost: 6)',
           'Gain a card to your hand costing up to 5. Put a card from your hand onto your deck.'
      action
      costs 6

      def play_as_action(played_by:)
        super

        game_state.get_journal(GainCardJournal, from: played_by).process(game_state)
      end

      class GainCardJournal < Journal
        define_question('Choose a card to gain into your hand').with_controls do |game_state|
          filter = ->(card) { card && card.cost <= 5 }
          [OneCardControl.new(player: @player,
                              scope: :supply,
                              text: 'Gain',
                              filter: filter,
                              null_choice: if game_state.piles.map(&:cards).map(&:first).none?(&filter)
                                             { text: 'Gain nothing', value: 'none' }
                                           end,
                              css_class: 'gain-card')]
        end

        validation do
          no_choices = journal.game_state.piles.map(&:cards).map(&:first).none? do |card|
            card && card.cost <= 5
          end
          return true if no_choices && journal.params['choice'] == 'none'
          return false if !no_choices && journal.params['choice'] == 'none'
          return false unless journal.params['choice'].integer?

          choice = journal.params['choice'].to_i
          choice < journal.game_state.piles.length &&
            ->(card) { card && card.cost <= 5 }[journal.game_state.piles[choice].cards.first]
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
          card.be_gained_by(player, from: pile.cards, to: :hand)

          game_state.get_journal(PlaceCardJournal, from: player).process(game_state)
        end
      end

      class PlaceCardJournal < Journal
        define_question('Choose a card to put onto your deck').with_controls do |_game_state|
          [OneCardControl.new(player: @player,
                              scope: :hand,
                              text: 'Put on deck',
                              null_choice: if @player.hand_cards.blank?
                                             { text: 'Put nothing on deck',
                                               value: 'none' }
                                           end)]
        end

        validation do
          return true if player.hand_cards.empty? && journal.params['choice'] == 'none'
          return false if player.hand_cards.present? && journal.params['choice'] == 'none'
          return false unless journal.params['choice'].integer?

          choice = journal.params['choice'].to_i
          choice < journal.player.hand_cards.length
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
        end
      end
    end
  end
end
