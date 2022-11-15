module CardDecorators
  module AttackDecorators
    # Get the attack card to handle attacking each of the victims.
    def launch_attack(victims:)
      game_state.in_parallel(victims) do |v|
        # Allow attack reactions until the player stops or runs out
        still_react = :continue
        response = {}
        reacted_cards = []
        while still_react == :continue && (locations = react_locations(v)).present?
          still_react = game_state.get_journal(GameEngine::ReactJournal,
                                               from: v,
                                               opts: {
                                                response: response,
                                                reacted_cards: reacted_cards,
                                                react_to: :attack,
                                                from: locations })
                                  .process(self)
        end

        attack(victim: v) unless response[:prevented]
      end
    end

    private

    def react_locations(ply)
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
      end.uniq
    end
  end
end
