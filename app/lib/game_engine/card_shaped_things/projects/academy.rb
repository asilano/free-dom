module GameEngine
  module CardShapedThings
    module Projects
      class Academy < Project
        text "When you gain an Action card, +1 Villager."
        costs 5

        def initialize(game_state)
          super

          filter = ->(card, *) { card.action? }
          Triggers::CardGained.watch_for(whenever: true, filter: filter) do |_card, gainer|
            next unless owners.include? gainer

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{gainer.name}.",
              player: gainer)
            gainer.villagers += 1
          end
        end
      end
    end
  end
end
