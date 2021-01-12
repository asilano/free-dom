module GameEngine
  module BaseGameV2
    class Witch < GameEngine::Card
      text 'Action/Attack (cost: 5)',
           '+2 Cards',
           'Each other player gains a Curse.'
      action
      attack
      costs 5

      def play_as_action(played_by:)
        super

        played_by.draw_cards(2)

        # Now, attack everyone else
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)
        # Victim gains a Curse
        Helpers.gain_card_from_supply(game_state,
          player:     victim,
          card_class: BasicCards::Curse)
      end
    end
  end
end
