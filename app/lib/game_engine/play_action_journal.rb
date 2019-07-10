module GameEngine
  class PlayActionJournal < Journal
    define_question('Play an Action, or pass').with_controls do |_game_state|
      [OneCardControl.new(player: @player,
                          scope: :hand,
                          text: 'Play',
                          filter: ->(card) { card.action? },
                          null_choice: { 'Leave Action Phase' => 'none' },
                          css_class: 'play-action')]
    end

    def process(game_state)
      super

      if params['choice'] == 'none'
        player.actions = 0
        @histories << History.new("#{player.name} stopped playing actions.",
                                  player: player)
        return
      end
    end
  end
end
