module GameEngine
  module Renaissance
    class CargoShip < Card
      text "+$2",
           "Once this turn, when you gain a card, you may set it aside face up (on this). At the start of your next turn, put it into your hand."
      action
      duration
      costs 3

      def play(played_by:)
        played_by.grant_cash(2)

        filter = lambda do |_, gainer, *|
          gainer == played_by
        end

        # Record who played the Cargo Ship, as it can get trashed but still work!
        GameEngine::Triggers::CardGained.watch_for(filter:   filter,
                                                   whenever: true,
                                                   opts:     { played_by: played_by },
                                                   stop_at:  :end_of_turn) { |*args, opts:| see_gain(*args, opts: opts) }
      end

      def see_gain(card, _player, _from, to, *, opts:)
        # Can't act on the gained card unless it's where it was gained to
        return unless card.location == to

        game_state.get_journal(SetAsideJournal,
                               from: opts[:played_by],
                               opts: { card: card, ship: self }).process(game_state)
      end

      def tracking?
        return false unless player

        player.cards.any? { |c| c.location == :set_aside && c.location_card == self }
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

          @histories << History.new("#{player.name} set aside #{opts[:card].readable_name} on Cargo Ship.",
                                    player: player)
          opts[:card].move_to :set_aside
          opts[:card].location_card = opts[:ship]
          opts[:ship].hosting << opts[:card]
          opts[:card].add_visibility_effect(self, to: :all, visible: true)

          filter = lambda do |turn_player|
            turn_player == player
          end
          Triggers::StartOfTurn.watch_for(filter: filter) do
            game.current_journal.histories << History.new("Cargo Ship returns #{opts[:card].readable_name} to #{player.name}'s hand.",
              player:      player,
              css_classes: %w[peek-cards])
            opts[:card].location = :hand
            opts[:card].location_card = nil
            opts[:ship].hosting.delete opts[:card]
          end
          :unwatch
        end
      end
    end
  end
end
