module GameEngine
  class HackJournal < Journal
    define_question('Hack the game state')

    process do |game_state|
      prevent_undo

      case params['scope']
      when 'hand', 'deck', 'discard', 'play'
        modify_player_cards(game_state)
      when 'supply'
        modify_supply_cards(game_state)
      when 'trash'
        modify_trash_cards(game_state)
      when 'artifact_owner'
        set_artifact_owner(game_state)
      when 'project_owner'
        set_project_owner(game_state)
      when 'villagers'
        set_player_villagers(game_state)
      when 'coffers'
        set_player_coffers(game_state)
      else
        raise InvalidJournalError, "Invalid journal: #{self}"
      end
    end

    def tag_along?
      true
    end

    private

    def modify_player_cards(game_state)
      location = params['scope']
      case params['action']
      when 'set'
        player.cards.delete_if { |c| c.location == location.to_sym }
      end

      params['cards'].each do |type|
        card = type.constantize.new(game_state)
        card.location = location.to_sym
        card.player = player
        player.cards << card
      end

      @histories << History.new("HACK! #{player.name}'s #{location} #{params['action']}: #{params['cards'].map(&:demodulize).map(&:titleize).join(', ')}.",
                                css_classes: %w[hack])
    end

    def modify_supply_cards(game_state)
      pile = game_state.piles.detect { |p| p.card_class.to_s == params['card_class'] }
      case params['action']
      when 'set'
        pile.cards.clear
      end

      params['cards'].each do |type|
        card = type.constantize.new(game_state)
        card.location = 'pile'
        pile.cards << card
      end

      @histories << History.new("HACK! #{params['card_class']} pile #{params['action']}: #{params['cards'].map(&:demodulize).map(&:titleize).join(', ')}.",
                                css_classes: %w[hack])
    end

    def modify_trash_cards(game_state)
      case params["action"]
      when "set"
        game_state.trashed_cards.clear
      end

      params["cards"].each do |type|
        card = type.constantize.new(game_state)
        card.location = "trash"
        game_state.trashed_cards << card
      end

      @histories << History.new("HACK! Trash cards #{params['action']}: #{params['cards'].map(&:demodulize).map(&:titleize).join(', ')}.",
                                css_classes: %w[hack])
    end

    def set_artifact_owner(game_state)
      game_state.artifacts[params['key']].give_to(player)

      @histories << History.new("HACK! Artifact #{params['key']} given to #{player.name}.",
                                css_classes: %w[hack])

    end

    def set_project_owner(game_state)
      card_shaped = game_state.card_shapeds.detect { |cl| cl.class.name == params["project"] }
      card_shaped.owners << player unless card_shaped.owners.include? player

      @histories << History.new("HACK! Project #{card_shaped.readable_name} given to #{player.name}.",
                                css_classes: %w[hack])

    end

    def set_player_villagers(game_state)
      player.villagers = params['count'].to_i

      @histories << History.new("HACK! #{player.name} now has #{params["count"]} villagers.",
                                css_classes: %w[hack])

    end

    def set_player_coffers(game_state)
      player.coffers = params['count'].to_i

      @histories << History.new("HACK! #{player.name} now has #{params["count"]} coffers.",
                                css_classes: %w[hack])

    end
  end
end
