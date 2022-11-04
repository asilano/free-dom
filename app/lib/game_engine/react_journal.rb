module GameEngine
  class ReactJournal < Journal
    define_question('React, or pass').prevent_auto
                                     .with_controls do |_game_state|
      filter = lambda do |card|
        card.reaction? &&
          card.reacts_to == opts[:react_to] &&
          (card.location == card.reacts_from || card.reacts_from == :everywhere)
      end
      opts[:from].map do |location|
        OneCardControl.new(journal_type: ReactJournal,
                           question:     self,
                           player:       @player,
                           scope:        location,
                           text:         'React',
                           filter:       filter,
                           null_choice:  { text:  'Stop reacting',
                                           value: 'none' },
                           params:       { scope: location },
                           css_class:    'react')
      end
    end

    validation do
      return true if params['choice'] == 'none'
      return false unless params['choice']&.integer?

      choice = params['choice'].to_i
      candidates = cards_in_scope(params["scope"]) or return false
      choice < candidates.length && candidates[choice].reaction?
    end

    process do |_game_state|
      if params['choice'] == 'none'
        return :stop
      end

      # Retrieve the card and make it react
      card = cards_in_scope(params["scope"])[params['choice'].to_i]
      card.react(opts[:response], reacted_by: player)
      :continue
    end

    def cards_in_scope(scope)
      case params["scope"]
      in "hand" | "deck" | "peeked" | "revealed"
        player.send("#{params["scope"]}_cards")
      in "play"
        player.played_cards
      in "discard"
        player.discarded_cards
      else
        false
      end
    end
  end
end
