module GameEngine
  module CardShapedThings
    module Projects
      class RoadNetwork < Project
        text "When another player gains a Victory card, +1 Card."
        costs 5

        def initialize(game_state)
          super

          filter = ->(card, *) { card.victory? }
          Triggers::CardGained.watch_for(whenever: true, filter: filter) do |_card, gainer|
            owners.each do |owner|
              next if owner == gainer

              game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{owner.name}.",
                player: owner)
              owner.draw_cards(1)
            end
          end
        end
      end
    end
  end
end
