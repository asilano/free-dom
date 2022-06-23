module GameEngine
  module CardShapedThings
    module Projects
      class CropRotation < Project
        text "At the start of your turn, you may discard a Victory card for +2 Cards."
        costs 6

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)
            game_state.get_journal(DiscardVictoryJournal, from: turn_player).process(game_state)
          end
        end

        class DiscardVictoryJournal < Journal
          define_question('Choose a Victory card to discard').with_controls do |_game_state|
            [OneCardControl.new(journal_type: DiscardVictoryJournal,
                                question:     self,
                                player:       @player,
                                scope:        :hand,
                                text:         "Discard",
                                filter:       :victory?,
                                null_choice:  { text: "Discard nothing", value: "none" },
                                css_class:    "discard-card")]
          end

          validation do
            return true if params["choice"] == "none"
            return false unless params["choice"]&.integer?

            choice = params["choice"].to_i
            choice < player.hand_cards.length && player.hand_cards[choice].victory?
          end

          process do |_game_state|
            if params["choice"] == "none"
              @histories << GameEngine::History.new("#{player.name} discarded nothing.",
                                                    player:      player,
                                                    css_classes: %w[discard-card])
              return
            end

            card = player.hand_cards[params["choice"].to_i]
            @histories << History.new("#{player.name} discarded #{card.readable_name}.",
                                      player:      player,
                                      css_classes: %w[discard-card])
            card.discard
            observe

            player.draw_cards(2)
          end
        end


      end
    end
  end
end
