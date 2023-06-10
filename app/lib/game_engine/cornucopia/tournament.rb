module GameEngine
  module Cornucopia
    class Tournament < Card
      text "+1 Action",
           "Each player may reveal a Province from their hand. If you do, discard it and gain any Prize (from " \
           "the Prize pile) or a Duchy, onto your deck. If no-one else does, +1 Card and +$1."
      action
      costs 4

      def play(played_by:)
        played_by.grant_actions(1)

        opts = {player_revealed: false, other_revealed: false, orig_player: played_by}
        game_state.in_parallel(game_state.players) do |ply|
          game_state.get_journal(RevealProvinceJournal, from: ply, opts:).process(self)
        end

        adjudicate_results(opts)
      end

      def adjudicate_results(results)
        results => {player_revealed:, other_revealed:, orig_player:}
        unless other_revealed
          orig_player.draw_cards(1)
          orig_player.grant_cash(1)
        end
      end

      class RevealProvinceJournal < Journal
        define_question do |_|
          opts => {player_revealed:, other_revealed:}
          player_str = "Tournament player has#{" not" unless player_revealed} revealed a Province"
          other_str = "#{other_revealed ? "at least one" : "no"} other player has revealed a Province"
          "Reveal Province, or decline (#{player_str}; #{other_str})"
        end.prevent_auto.with_controls do |_|
          [OneCardControl.new(journal_type: RevealProvinceJournal,
                              question:     self,
                              player:       @player,
                              scope:        :hand,
                              text:         "Reveal",
                              filter:       ->(card) { card.is_a? BasicCards::Province },
                              null_choice:  { text:  "Reveal nothing",
                                              value: "dont_reveal" },
                              css_class:    "reveal-card")]
        end

        validation do
          return true if params["choice"] == "dont_reveal"
          return false unless params["choice"]&.integer?
          return player.hand_cards[params["choice".to_i]].is_a? BasicCards::Province
        end

        process do |_|
          if params["choice"] == "dont_reveal"
            @histories << GameEngine::History.new("#{player.name} revealed nothing.",
                                                  player:,
                                                  css_classes: %w[reveal-card])
            return
          end

          @histories << GameEngine::History.new("#{player.name} revealed a Province.",
                                                player:,
                                                css_classes: %w[reveal-card])
          if player == opts[:orig_player]
            opts[:player_revealed] = true
            opts[:to_discard] = player.hand_cards[params["choice".to_i]]
          else
            opts[:other_revealed] = true
          end
        end
      end
    end
  end
end
