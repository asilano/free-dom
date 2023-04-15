module GameEngine
  module Cornucopia
    class HorseTraders < Card
      text "+1 Buy",
           "+$3",
           "Discard 2 cards.",
           :hr,
           "When another player plays an Attack card, you may first set this aside from your hand. " \
           "If you do, then at the start of your next turn, +1 Card and return this to your hand."
      action
      reaction from: :hand, to: :attack
      costs 4

      def play(played_by:)
        played_by.grant_buys(1)
        played_by.cash += 3

        count = [2, played_by.hand_cards.count].min
        return if count.zero?

        game_state.get_journal(DiscardCardsJournal, from: played_by, opts: { count: }).process(game_state)
      end

      def react(response, reacted_by:)
        super
        set_aside

        horse_traders = self
        filter = lambda do |turn_player|
          turn_player == reacted_by
        end
        Triggers::StartOfTurn.watch_for(filter:) do
          game.current_journal.histories << History.new("Horse Traders returns to #{reacted_by.name}'s hand.",
            player: reacted_by,
            css_classes: %w[])
          horse_traders.return_from_set_aside to: :hand
          reacted_by.draw_cards(1)
          observe
        end
      end

      class DiscardCardsJournal < Journal
        define_question do |_game_state|
          "Discard #{pluralize(opts[:count], "card")}"
        end.with_controls do |_game_state|
          [MultiCardControl.new(journal_type: DiscardCardsJournal,
                                question:     self,
                                player:       @player,
                                scope:        :hand,
                                text:         "Discard",
                                submit_text:  "Discard selected cards",
                                css_class:    "discard")]
        end

        validation do
          return false unless params["choice"].length == opts[:count]
          return false unless params["choice"]&.all?(&:integer?)

          params["choice"].all? do |choice|
            choice.to_i < player.hand_cards.length
          end
        end

        process do |game_state|
          # Just log if the player chose nothing
          if params["choice"].blank?
            @histories << History.new("#{player.name} discarded nothing",
                                      player:,
                                      css_classes: %w[discard])
            return
          end

          # Discard all the chosen cards in hand order
          cards = params["choice"].map { |ch| player.hand_cards[ch.to_i] }
          texts_for_history = cards.map(&:readable_name)
          cards.each(&:discard)
          @histories << History.new("#{player.name} discarded #{texts_for_history.join(", ")}",
                                    player:,
                                    css_classes: %w[discard])

          game_state.observe
        end
      end
    end
  end
end
