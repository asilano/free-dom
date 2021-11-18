module GameEngine
  class PlayActionJournal < Journal
    define_question { |_| player.actions.zero? ? "Leave the Action phase" : "Play an Action, or pass" }
        .prevent_auto
        .with_controls do |_game_state|
      filter = -> (card) { @player.actions.zero? ? false : card.action? }
      [OneCardControl.new(journal_type: PlayActionJournal,
                          question:     self,
                          player:       @player,
                          scope:        :hand,
                          text:         'Play',
                          filter:       filter,
                          null_choice:  { text:  'Leave Action Phase',
                                          value: 'none' },
                          css_class:    'play-action')]
    end

    validation do
      valid_hand_card(filter: ->(card) { card.action? })
    end

    process do |_game_state|
      if params['choice'] == 'none'
        @histories << History.new("#{player.name} stopped playing actions.",
                                  player: player,
                                  css_classes: %w[play-action])
        return :stop
      end

      # Charge the player an Action-play slot
      player.actions -= 1

      # Retrieve the card and make it play itself
      card = player.hand_cards[params['choice'].to_i]
      card.play_as_action(played_by: player)
    end
  end
end
