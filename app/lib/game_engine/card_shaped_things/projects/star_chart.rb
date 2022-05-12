module GameEngine
  module CardShapedThings
    module Projects
      class StarChart < Project
        text "When you shuffle, you may pick one of the cards to go on top."
        costs 3

        def initialize(game_state)
          super(game_state)

          Triggers::Shuffle.watch_for(whenever: true) do |shuffler|
            @old_shuffle = Array.instance_method(:shuffle)

            if owners.include? shuffler
              game_state.game.current_journal.histories << History.new("#{readable_name} triggered for #{shuffler.name}.",
                player: shuffler)

              game_state.get_journal(FloatCardJournal,
                                     from: shuffler,
                                     opts: { old_shuffle: @old_shuffle })
                        .process(shuffler)
            end
          end.cleanup_with { Array.define_method(:shuffle, @old_shuffle) }
        end

        class FloatCardJournal < Journal
          define_question("Choose a card to put on top of shuffle").with_controls do |_game_state|
            [OneCardControl.new(journal_type: FloatCardJournal,
                                question:     self,
                                player:       @player,
                                scope:        :discard,
                                text:         "Put on top",
                                null_choice:  { text: "Leave to chance", value: "none" })]
          end

          validation do
            return true if params["choice"] == "none"
            return false unless params["choice"]&.integer?

            choice = params["choice"].to_i
            choice < player.discarded_cards.length
          end

          process do |_game_state|
            # Just log if the player chose nothing
            if params["choice"] == "none"
              @histories << History.new("#{player.name} chose no particular card to put on top.",
                                        player: player)
              return
            end

            card = player.discarded_cards[params["choice"].to_i]

            log = "#{player.name} chose to put " +
            History.personal_log(private_to: player.user,
                                 private_msg: card.readable_name,
                                 public_msg: "a card") +
            " on top."
            @histories << History.new(log, player: player)

            old_shuffle = opts[:old_shuffle]
            Array.define_method(:shuffle) do |random: Random|
              delete card
              old_shuffle.bind_call(self, random: random).unshift(card)
            end
          end
        end
      end
    end
  end
end
