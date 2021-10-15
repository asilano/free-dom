module GameEngine
  module Renaissance
    class Experiment < Card
      text "Action (cost: 3)",
           "+2 Cards",
           "+1 Action",
           "Return this to the Supply.",
           :hr,
           "When you gain this, gain another Experiment (that doesn't come with another)."
      action
      costs 3
      on_gain do |card, player, _from|
        unless card.facts[:experiment_result]
          Helpers.gain_card_from_supply(
            card.game_state,
            player: player,
            card_class: self,
            tap_card: -> (c) { c.facts[:experiment_result] = true })
        end

        card.facts.delete(:experiment_result)
      end

      def play_as_action(played_by:)
        super

        played_by.draw_cards(2)
        played_by.grant_actions(1)
        return_to_supply
      end
    end
  end
end
