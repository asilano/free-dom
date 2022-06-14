module GameEngine
  module CardShapedThings
    module Projects
      class SinisterPlot < Project
        text "At the start of your turn, add a token here, or remove your tokens here for +1 Card each."
        costs 4

        attr_reader :player_tokens

        def initialize(game_state)
          super
          @player_tokens = {}

          Triggers::StartOfTurn.watch_for(whenever: true) do |turn_player|
            next unless owners.include? turn_player

            game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{turn_player.name}.",
                                                                     player: turn_player)
            game_state.get_journal(AddOrRemoveTokenJournal,
                                   from: turn_player,
                                   opts: {plot: self}).process(game_state)
          end
        end

        def be_bought_by(player)
          super
          player_tokens[player] = 0
        end

        def text_for(owner)
          super + " - #{pluralize(player_tokens[owner], "token")}"
        end

        class AddOrRemoveTokenJournal < Journal
          define_question("Choose whether to add a token or remove your tokens").with_controls do |game_state|
            opts = [["Add a token", "add"], ["Remove your tokens", "remove"]]
            [ButtonControl.new(journal_type: AddOrRemoveTokenJournal,
                               question:     self,
                               player:       @player,
                               scope:        :player,
                               values:       opts)]
          end

          validation do
            %w[add remove].include? params["choice"]
          end

          process do |_game_state|
            tokens = opts[:plot].player_tokens
            case params["choice"]
            when "add"
              tokens[player] += 1
              @histories << History.new("#{player.name} chose to add a token to #{opts[:plot].readable_name} (new total: #{tokens[player]}).",
                                        player: player)
            when "remove"
              @histories << History.new("#{player.name} chose to remove their tokens from #{opts[:plot].readable_name}.",
                                        player: player)
              player.draw_cards(tokens[player])
              tokens[player] = 0
            end
          end
        end
      end
    end
  end
end
