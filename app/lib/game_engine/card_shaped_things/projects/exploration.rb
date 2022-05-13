module GameEngine
  module CardShapedThings
    module Projects
      class Exploration < Project
        text "At the end of your Buy phase, if you didn't buy any cards during it, +1 Coffers and +1 Villager."
        costs 4

        def initialize(game_state)
          super(game_state)

          Triggers::StartOfBuyPhase.watch_for(whenever: true) do |_turn_player|
            self.bought_this_turn = false
          end

          Triggers::CardBought.watch_for(whenever: true) do |_card, _buyer|
            self.bought_this_turn = true
          end

          Triggers::EndOfBuyPhase.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player
            next if bought_this_turn

            turn_player.coffers += 1
            turn_player.villagers += 1
            game_state.game.current_journal.histories << History.new("#{readable_name} granted #{turn_player.name} 1 Coffers and 1 Villager.",
                                                                     player: turn_player)
          end
        end

        private

        attr_accessor :bought_this_turn

      end
    end
  end
end
