module GameEngine
  class HackJournal < Journal
    process do |game_state|
      prevent_undo

      case params['scope']
      when 'hand'
        modify_hand(game_state)
      end
    end

    def modify_hand(game_state)
      case params['action']
      when 'set'
        player.cards.delete_if { |c| c.location == :hand }
      end

      params['cards'].each do |type|
        card = type.constantize.new(game_state)
        card.location = :hand
        player.cards << card
      end

      @histories << History.new("HACK! #{player.name}'s hand #{params['action']}: #{params['cards'].map(&:demodulize).map(&:titleize).join(', ')}.")
    end
  end
end