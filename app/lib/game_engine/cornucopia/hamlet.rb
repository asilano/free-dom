module GameEngine
  module Cornucopia
    class Hamlet < Card
      text "+1 Card",
           "+1 Action",
           "You may discard a card for +1 Action.",
           "You may discard a card for +1 Buy."
      action
      costs 2

      def play(played_by:)
        played_by.draw_cards(1)
        played_by.grant_actions(1)
        game_state.get_journal(DiscardForActionJournal, from: played_by).process(game_state)
        game_state.get_journal(DiscardForBuyJournal, from: played_by).process(game_state)
      end

      class DiscardForBenefitJournal < Journal
        def self.benefit(article, benefit_text)
          define_singleton_method(:benefit_text) { benefit_text }

          define_question { |_| "Discard a card to get #{article} #{benefit_text}" }.with_controls do |_game_state|
            [OneCardControl.new(journal_type: journal_type,
                                question:     self,
                                player:       @player,
                                scope:        :hand,
                                text:         "Discard",
                                null_choice:  { text: "Discard nothing (for #{benefit_text})",
                                                value: "none" },
                                css_class:    "discard-card")]
          end
        end


        validation do
          valid_hand_card(allow_decline: true)
        end

        process do |_game_state|
          if params["choice"] == "none"
            @histories << GameEngine::History.new("#{player.name} discarded nothing (for #{self.class.benefit_text}).",
                                                  player:      player,
                                                  css_classes: %w[discard-card])
            return
          end

          # Have the player discard the chosen card
          card = player.hand_cards[params['choice'].to_i]
          @histories << History.new("#{player.name} discarded #{card.readable_name} for +1 #{self.class.benefit_text}.",
                                    player:      player,
                                    css_classes: %w[discard-card])
          card.discard
          observe

          grant_benefit
        end
      end

      class DiscardForActionJournal < DiscardForBenefitJournal
        benefit "an", "Action"
        def grant_benefit
          player.grant_actions(1)
        end
      end

      class DiscardForBuyJournal < DiscardForBenefitJournal
        benefit "a", "Buy"
        def grant_benefit
          player.grant_buys(1)
        end
      end
    end
  end
end
