module GameEngine
  class SpendCoffersJournal < Journal
    validation do
      params['choice'].integer? && (1..player.coffers).include?(params['choice'].to_i)
    end

    process do |_game_state|
      count = params['choice'].to_i
      player.coffers -= count
      player.cash += count

      @histories << GameEngine::History.new("#{player.name} spent #{count} Coffers (total: $#{player.cash}).",
                                            player: player,
                                            css_classes: [])
    end
  end
end
