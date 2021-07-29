module GameEngine
  module BaseGameV2
    class Cellar < GameEngine::Card
      text 'Action (cost: 2) — +1 Action',
           'Discard any number of cards, then draw that many.'
      action
      costs 2

      def play_as_action(played_by:)
        super

        played_by.grant_actions(1)
        game_state.get_journal(DiscardCardsJournal, from: played_by).process(game_state)
      end

      class DiscardCardsJournal < Journal
        define_question('Discard any number of cards').with_controls do |game_state|
          [MultiCardControl.new(journal_type: DiscardCardsJournal,
                                question:     self,
                                player:       @player,
                                scope:        :hand,
                                text:         'Discard',
                                submit_text:  'Discard selected cards',
                                css_class:    'discard')]
        end

        validation do
          return true if params['choice'].blank?
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

          # Draw that many replacements
          player.draw_cards(params['choice'].length)
        end
      end
    end
  end
end
