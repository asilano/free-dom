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
        GameEngine::Triggers::CardGained.watch_for(filter:,
                                                   whenever: true,
                                                   opts:     { played_by: },
                                                   stop_at:  :end_of_turn) { |*args, opts:| see_gain(*args, opts: opts) }
      end

      def see_gain(card, _player, _from, to, *, opts:)
        # Can't act on the gained card unless it's where it was gained to
        return unless card.location == to

        game_state.get_journal(SetAsideJournal,
                               from: opts[:played_by],
                               opts: { card:, ship: self }).process(game_state)
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
                                      player:)
            return
          end

          @histories << History.new("#{player.name} set aside #{opts[:card].readable_name} on Cargo Ship.",
                                    player:)
          opts[:card].set_aside on: opts[:ship]
          opts[:card].add_visibility_effect(self, to: :all, visible: true)

          filter = lambda do |turn_player|
            turn_player == player
          end
          Triggers::StartOfTurn.watch_for(filter: filter) do
            game.current_journal.histories << History.new("Cargo Ship returns #{opts[:card].readable_name} to #{player.name}'s hand.",
              player:,
              css_classes: %w[peek-cards])
            opts[:card].return_from_set_aside to: :hand
          end
          :unwatch
        end
      end
    end
  end
end
