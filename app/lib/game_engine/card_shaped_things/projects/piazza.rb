module GameEngine
  module CardShapedThings
    module Projects
      class Piazza < Project
        text "At the start of your turn, reveal the top card of your deck. If it's an Action, play it."
        costs 5

        def initialize(game_state)
          super

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)

            top_of_deck = turn_player.reveal_cards(1, from: :deck).first

            next unless top_of_deck

            if top_of_deck.action?
              top_of_deck.play_card(played_by: turn_player)
            else
              top_of_deck.be_unrevealed
            end
          end
        end
      end
    end
  end
end
