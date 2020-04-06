module GameEngine
  class PlayActionJournal < Journal
    define_question('Play an Action, or pass').with_controls do |_game_state|
      [OneCardControl.new(journal_type: PlayActionJournal,
                          player: @player,
                          scope: :hand,
                          text: 'Play',
                          filter: ->(card) { card.action? },
                          null_choice: { text: 'Leave Action Phase',
                                         value: 'none' },
                          css_class: 'play-action')]
    end

    validation do
      return true if journal.params['choice'] == 'none'
      return false unless journal.params['choice'].integer?

      choice = journal.params['choice'].to_i
      choice < journal.player.hand_cards.length && journal.player.hand_cards[choice].action?
    end

    process do |_game_state|
      if params['choice'] == 'none'
        player.actions = 0
        @histories << History.new("#{player.name} stopped playing actions.",
                                  player: player,
                                  css_classes: %w[play-action])
        return
      end

      # Charge the player an Action-play slot
      player.actions -= 1

      # Retrieve the card and make it play itself
      card = player.hand_cards[params['choice'].to_i]
      card.play_as_action(played_by: player)
    end
  end
end
