module GameEngine
  module Renaissance
    class Scepter < Card
      text "When you play this, choose one: +$2; or replay an Action card you played this turn that's still in play."
      treasure special: true
      costs 5

      attr_accessor :replayed

      def play(played_by:)
        game_state.get_journal(ChooseModeJournal, from: played_by, opts: { original: self }).process(game_state)
      end

      def tracking?
        replayed&.tracking?
      end

      class ChooseModeJournal < Journal
        define_question("Choose mode for Scepter").with_controls do |_|
          [ButtonControl.new(journal_type: ChooseModeJournal,
                             question:     self,
                             player:       @player,
                             scope:        :player,
                             values:       [["Gain cash", "cash"], ["Replay Action", "action"]])]
        end

        validation do
          %w[cash action].include? params["choice"]
        end

        process do |game_state|
          if params["choice"] == "cash"
            player.grant_cash(2)
            @histories << History.new("#{player.name} chose to take cash from #{Scepter.readable_name}.",
                                      player: player)
            return
          end

          @histories << History.new("#{player.name} chose to replay an action with #{Scepter.readable_name}.",
                                    player: player)
          game_state.get_journal(ChooseActionJournal, from: player, opts: { original: opts[:original] }).process(game_state)
        end
      end

      class ChooseActionJournal < Journal
        define_question('Choose an Action to replay').with_controls do |_game_state|
          filter = ->(card) { card.action? && card.played_this_turn }
          [OneCardControl.new(journal_type: ChooseActionJournal,
                              question:     self,
                              player:       @player,
                              scope:        :play,
                              text:         "Replay",
                              filter:       filter,
                              null_choice:  if @player.played_cards.none?(&:action?)
                                              { text: "Choose nothing", value: "none" }
                                            end,
                              css_class:    "play-action")]
        end

        validation do
          valid_played_card(filter: ->(card) { card.action? && card.played_this_turn })
        end

        process do |_game_state|
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} chose not to replay anything.",
                                      player:      player,
                                      css_classes: %w[play-action])
            return
          end

          # Note the chosen card, then stop noting it when Scepter is discarded. This lets us track if the replayed
          # card is.
          card = player.played_cards[params['choice'].to_i]
          opts[:original].replayed = card

          @histories << History.new("#{player.name} chose to replay #{card.readable_name}.",
                                    player:      player,
                                    css_classes: %w[play-action])

          # Play the chosen card
          card.play(played_by: player)
        end
      end

    end
  end
end
