module GameEngine
  module CardShapedThings
    module Projects
      class Pageant < Project
        text "At the end of your Buy phase, you may pay $1 for +1 Coffers."
        costs 3

        def initialize(game_state)
          super

          Triggers::EndOfBuyPhase.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)

            if turn_player.cash < 1
              game_state.game.current_journal.histories << History.new("#{turn_player.name} had no cash.",
                                                                       player: turn_player)
              next
            end

            game_state.get_journal(PayForCoffersJournal, from: turn_player).process(turn_player)
          end
        end

        class PayForCoffersJournal < Journal
          define_question("Choose whether to spend $1 for +1 Coffers").with_controls do |_|
            opts = [["Spend $1", "pay"], ["Decline", "none"]]
            [ButtonControl.new(journal_type: PayForCoffersJournal,
                               question:     self,
                               player:       @player,
                               scope:        :player,
                               values:       opts)]
          end

          validation do
            %w[none pay].include? params["choice"]
          end

          process do |_game_state|
            if params["choice"] == "none"
              @histories << History.new("#{player.name} chose not to pay for a Coffers.",
                                        player: player)
              return
            end

            player.coffers += 1
            player.cash -= 1

            @histories << History.new("#{player.name} paid $1 and gained 1 Coffers.",
                                      player: player)
          end
        end
      end
    end
  end
end
