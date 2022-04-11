module CardDecorators
  module AttackDecorators
    # Get the attack card to handle attacking each of the victims.
    def launch_attack(victims:)
      game_state.in_parallel(victims) do |v|
        # Allow attack reactions until the player stops or runs out
        has_reacts_proc = ->(ply) do
          ply.cards.any? do |card|
            card.reaction? &&
              card.reacts_to == :attack &&
              card.location == card.reacts_from
          end
        end
        still_react = :continue
        response = {}
        while still_react == :continue && has_reacts_proc[v]

          still_react = game_state.get_journal(GameEngine::ReactJournal,
                                               from: v,
                                               opts: { response: response, react_to: :attack }).process(self)
        end

        attack(victim: v) unless response[:prevented]
      end
    end
  end
end
