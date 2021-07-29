module GameEngine
  module BaseGameV2
    class Poacher < GameEngine::Card
      text 'Action (cost: 4)',
           '+1 Card',
           '+1 Action',
           '+1 Cash',
           'Discard a card per empty Supply pile.'
      action
      costs 4

      def play_as_action(played_by:)
        super

        played_by.draw_cards(1)
        observe
        played_by.grant_actions(1)
        played_by.grant_cash(1)

        if game_state.piles.any? { |p| p.cards.empty? }
          count = game_state.piles.count { |p| p.cards.empty? }.clamp(0, @player.hand_cards.count)
          game_state.get_journal(DiscardCardsJournal, from: played_by, opts: { count: count }).process(game_state)
        end
      end

      class DiscardCardsJournal < Journal
        define_question do |_game_state|
          "Discard #{pluralize(opts[:count], 'card')}"
        end.with_controls do |_game_state|
          [MultiCardControl.new(journal_type: DiscardCardsJournal,
                                question:     self,
                                player:       @player,
                                scope:        :hand,
                                text:         'Discard',
                                submit_text:  'Discard selected cards',
                                css_class:    'discard')]
        end

        validation do
          return false unless params['choice'].length == opts[:count]
          return false unless params['choice']&.all?(&:integer?)

          params['choice'].all? do |choice|
            choice.to_i < player.hand_cards.length
          end
        end

        process do |game_state|
          # Just log if the player chose nothing
          if params['choice'].blank?
            @histories << History.new("#{player.name} discarded nothing",
                              player:      player,
                              css_classes: %w[discard])
            return
          end

          # Discard all the chosen cards in hand order
          cards = params['choice'].map { |ch| player.hand_cards[ch.to_i] }
          texts_for_history = cards.map(&:readable_name)
          cards.each(&:discard)
          @histories << History.new("#{player.name} discarded #{texts_for_history.join(', ')}",
                                    player:      player,
                                    css_classes: %w[discard])

          game_state.observe
        end
      end
    end
  end
end
