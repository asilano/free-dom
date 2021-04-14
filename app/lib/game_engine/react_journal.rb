module GameEngine
  class ReactJournal < Journal
    define_question('React, or pass').prevent_auto
                                     .with_controls do |_game_state|
      filter = lambda do |card|
        card.reaction? &&
          card.reacts_to == @opts[:react_to] &&
          card.location == card.reacts_from
      end
      [OneCardControl.new(journal_type: ReactJournal,
                          question:     self,
                          player:       @player,
                          scope:        :everywhere,
                          text:         'React',
                          filter:       filter,
                          null_choice:  { text:  'Stop reacting',
                                          value: 'none' },
                          css_class:    'react')]
    end

    validation do
      return true if journal.params['choice'] == 'none'
      return false unless journal.params['choice']&.integer?

      choice = journal.params['choice'].to_i
      choice < journal.player.cards.length && journal.player.cards[choice].reaction?
    end

    process do |_game_state|
      if params['choice'] == 'none'
        return :stop
      end

      # Retrieve the card and make it react
      card = player.cards[params['choice'].to_i]
      card.react(opts[:response], reacted_by: player)
      :continue
    end
  end
end
