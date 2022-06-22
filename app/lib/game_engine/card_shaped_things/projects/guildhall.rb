module GameEngine
  module CardShapedThings
    module Projects
      class Guildhall < Project
        text "When you gain a Treasure, +1 Coffers."
        costs 5

        def initialize(game_state)
          super

          filter = ->(card, *) { card.treasure? }
          Triggers::CardGained.watch_for(whenever: true, filter: filter) do |_card, gainer|
            next unless owners.include? gainer

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{gainer.name}.",
              player: gainer)
            gainer.coffers += 1
          end
        end
      end
    end
  end
end
