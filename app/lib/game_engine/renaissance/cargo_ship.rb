module GameEngine
  module Renaissance
    class CargoShip < Card
      text "Action - Duration (cost: 3)",
           "+2 Cash",
           "Once this turn, when you gain a card, you may set it aside face up (on this). At the start of your next turn, put it into your hand."
      action
      duration
      costs 3

      def play_as_action(played_by:)
        super

        played_by.grant_cash(2)

        filter = lambda do |_, gainer, *|
          gainer == played_by
        end
        GameEngine::Triggers::CardGained.watch_for(filter:   filter,
                                                   whenever: true) { |*args| see_gain(*args) }
      end

      def see_gain(card, *)
        game_state.get_journal(SetAsideJournal,
                               from: player,
                               opts: { card: card, ship: self }).process(game_state)
      end

      def tracking?
        player.try do |ply|
          ply.cards.any? { |c| c.location == :set_aside && c.location_card == self }
        end
      end

      class SetAsideJournal < Journal
        define_question { |_| "Choose whether to set aside #{opts[:card].readable_name} on Cargo Ship" }
          .with_controls do |_game_state|
            [ButtonControl.new(journal_type: SetAsideJournal,
                               question:     self,
                               player:       @player,
                               scope:        :player,
                               values:       [["Set aside", "set-aside"],
                                              ["Don't set aside", "decline"]])]
          end

        validation do
          %w[set-aside decline].include? params["choice"]
        end

        process do |_game_state|
          if params["choice"] == "decline"
            @histories << History.new("#{player.name} chose not to set aside #{opts[:card].readable_name} on Cargo Ship.",
                                      player: player)
            return
          end

          opts[:card].location = :set_aside
          opts[:card].location_card = opts[:ship]

          filter = lambda do |turn_player|
            turn_player == player
          end
          Triggers::StartOfTurn.watch_for(filter: filter) do
            opts[:card].location = :hand
            opts[:card].location_card = nil
          end
          :unwatch
        end
      end
    end
  end
end
