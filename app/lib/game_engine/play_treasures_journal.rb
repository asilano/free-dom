module GameEngine
  class PlayTreasuresJournal < Journal
    define_question('Play Treasures, or pass').with_controls do |_game_state|
      [MultiCardControl.new(player: @player,
                            scope: :hand,
                            text: 'Play',
                            filter: ->(card) { card.treasure? },
                            null_choice: { 'Stop playing treasures' => 'none' },
                            css_class: 'play-treasure')]
    end

    def process(game_state)
      super

      # if params['choice'] == 'none'
      #   player.actions = 0
      #   @histories << History.new("#{player.name} stopped playing actions.")
      #   return
      # end
      :continue
    end
  end
end
