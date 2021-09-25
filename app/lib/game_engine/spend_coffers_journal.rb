module GameEngine
  class SpendCoffersJournal < Journal
    define_question("Spend Coffers").prevent_auto
                                    .with_controls do |_game_state|
      [NumberControl.new(
        journal_type: SpendCoffersJournal,
        question:     self,
        player:       @player,
        scope:        :with_hand,
        min:          1,
        max:          @player.coffers,
        text:         "Coffers to spend (max: #{@player.coffers})",
        submit_text:  "Spend coffers"
      )]
    end

    validation do
      params["choice"].integer? &&
        (1..player.coffers).include?(params["choice"].to_i)
    end

    process do |_game_state|
      count = params["choice"].to_i
      player.coffers -= count
      player.cash += count

      @histories << GameEngine::History.new("#{player.name} spent #{count} Coffers (total: $#{player.cash}).",
                                            player: player,
                                            css_classes: [])
    end

    def tag_along?
      true
    end
  end
end
