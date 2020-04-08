module GameEngine
  class HackJournal < Journal
    process do |game_state|
      prevent_undo

      case params['scope']
      when 'hand', 'deck', 'discard'
        modify_player_cards(game_state, params['scope'])
      end
    end

    def modify_player_cards(game_state, location)
      case params['action']
      when 'set'
        player.cards.delete_if { |c| c.location == location.to_sym }
      end

      params['cards'].each do |type|
        card = type.constantize.new(game_state)
        card.location = location.to_sym
        player.cards << card
      end

      @histories << History.new("HACK! #{player.name}'s #{location} #{params['action']}: #{params['cards'].map(&:demodulize).map(&:titleize).join(', ')}.",
                                css_classes: %w[hack])
    end
  end
end