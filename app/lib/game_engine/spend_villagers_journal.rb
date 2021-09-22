module GameEngine
  class SpendVillagersJournal < Journal
    define_question("Spend Villagers").prevent_auto
                                      .with_controls do |_game_state|
      [NumberControl.new(
        journal_type: SpendVillagersJournal,
        question:     self,
        player:       @player,
        scope:        :with_hand,
        min:          1,
        max:          @player.villagers,
        text:         "Villagers to spend (max: #{@player.villagers})",
        submit_text:  "Spend villagers"
      )]
    end

    validation do
      params['choice'].integer? &&
        (1..player.villagers).include?(params['choice'].to_i) &&
        true
    end

    process do |_game_state|
      count = params['choice'].to_i
      player.villagers -= count
      player.actions += count

      @histories << GameEngine::History.new("#{player.name} spent #{count} Villagers.",
                                            player: player,
                                            css_classes: [])
    end

    def tag_along?
      true
    end
  end
end
