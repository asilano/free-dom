module CardDecorators
  module AttackDecorators
    # Get the attack card to handle attacking each of the victims.
    def launch_attack(victims:)
      game_state.in_parallel(victims) do |v|
        # Allow attack reactions until the player stops or runs out
        get_react_locations = ->(ply) do
          ply.cards.filter_map do |card|
            if card.reaction? && card.reacts_to == :attack &&
                (card.location == card.reacts_from || card.reacts_from == :everywhere)
              if card.peeked
                :peeked
              elsif card.revealed
                :revealed
              else
                card.location
              end
            end
          end
        end
        still_react = :continue
        response = {}
        while still_react == :continue && (locations = get_react_locations[v]).present?
          still_react = game_state.get_journal(GameEngine::ReactJournal,
                                               from: v,
                                               opts: { response: response, react_to: :attack, from: locations })
                                  .process(self)
        end

        attack(victim: v) unless response[:prevented]
      end
    end
  end
end
