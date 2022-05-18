module GameEngine
  module CardShapedThings
    module Projects
      class CityGate < Project
        text "At the start of your turn, +1 Card, then put a card from your hand onto your deck."
        costs 3

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)

            turn_player.draw_cards(1)
            game_state.get_journal(PlaceCardJournal, from: turn_player).process(turn_player)
          end
        end

        class PlaceCardJournal < Journal
          define_question("Choose a card to put on your deck").with_controls do |_game_state|
            [OneCardControl.new(journal_type: PlaceCardJournal,
                                question:     self,
                                player:       @player,
                                scope:        :hand,
                                text:         "Place",
                                null_choice:  if @player.hand_cards.empty?
                                                { text: "Place nothing", value: "none" }
                                              end,
                                css_class:    "place-card")]
          end

          validation do
            return false if params["choice"] == "none" && !player.hand_cards.empty?
            return true if params["choice"] == "none" && player.hand_cards.empty?

            params["choice"]&.integer? && params["choice"].to_i < player.hand_cards.length
          end

          process do |_game_state|
            if params["choice"] == "none"
              @histories << History.new("#{player.name} didn't place a card onto their deck.",
                                        player:      player,
                                        css_classes: %w[place-card])
              return
            end

            # Place the chosen card on its owner's deck
            card = player.hand_cards[params["choice"].to_i]
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
end
