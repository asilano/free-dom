module GameEngine
  module Renaissance
    class FlagBearer < Card
      text "+2 Cash",
           :hr,
           "When you gain or trash this, take the Flag."
      action
      costs 4

      # Flag - When drawing your hand, +1 Card

      setup do |game_state|
        game_state.create_artifact(CardShapedThings::Artifacts::Flag)
      end

      take_flag = ->(_card, player, *_) {
        player.game_state.artifacts['Flag'].give_to(player)
        player.game.current_journal.histories << History.new("#{player.name} took the Flag.",
                                                             player: player)
      }
      on_gain(&take_flag)
      on_trash(&take_flag)

      def play(played_by:)
        played_by.grant_cash(2)
      end
    end
  end
end
