class PromoCards::Prince < Card
  action
  costs 8
  card_text "Action (cost: 8) - You may set this aside. If you do, set aside an Action card from your hand costing up to 4. " +
            "At the start of each of your turns, play that Action, setting it aside again when you discard it from play. " +
            "(Stop playing it if you fail to set it aside on a turn you play it.)"

  def play(parent_act)
    super

    # it's explicitly ruled that you can't set two cards aside if you've used Throne Room or King's Court.
    # If this is not the last ThroneRoomed or KingsCourted copy of this card, then parent_act will
    # be another one. Only add the set-aside action if it isn't.
    if parent_act.expected_action !~ /resolve_.*(ThroneRoom|KingsCourt).*_playaction;type=#{self.class};id=#{id}/
      # Ask the player to choose the action to set aside.
      # We do this even if there's only one (or no!) valid action, since Prince is actually optional
      parent_act.children.create!(expected_action: "resolve_#{self.class}#{id}_choose",
                                  text: 'Choose a card to set aside with Prince',
                                  game: game,
                                  player: player)
    end
    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when 'choose'
      # Can always choose not to set Prince aside. But can only set it aside alone if there are no
      # suitable cards in hand.
      nil_actions = ['Leave Prince in play']
      nil_actions << 'Set Prince aside alone' if player.cards.hand.none? { |c| c.is_action? && c.cost <= 4 }
      controls[:hand] += [{type: :button,
                           text: 'Set aside',
                           nil_action: nil_actions,
                           params:  {card:  "#{self.class}#{id}",
                                      substep: 'choose'},
                           cards: player.cards.hand.map do |card|
                             card.is_action? && card.cost <= 4
                           end
                          }]
    end
  end

  resolves(:choose).validating_params_has_any_of(:card_index, :nil_action).
                    validating_param_is_card(:card_index, scope: :hand) { is_action? && cost <= 4 }.
                    validating_param_satisfies(:nil_action) { |type, card|  type != 'Set Prince aside alone' || card.player.cards.hand.none? { |c| c.is_action? && c.cost <= 4 } }.
                    with do
    if params[:nil_action].andand == 'Leave Prince in play'
      # Player chose to leave Prince in play. This is legitimate. Just log - nothing else to do.
      game.histories.create!(event: "#{actor.name} chose not to set #{self} aside.",
                              css_class: "player#{actor.seat}")
    elsif params[:nil_action].andand == 'Set Prince aside alone'
      # Player chose to set Prince aside without an action card.
      self.location = 'prince'
      save!

      game.histories.create!(event: "#{actor.name} set aside #{self} alone.",
                              css_class: "player#{actor.seat}")
    else
      # Player chose an action card to set aside. Move both Prince and the chosen card to a "prince" zone,
      # and update Prince's state to point to the action card
      chosen = actor.cards.hand[params[:card_index].to_i]
      chosen.update_attributes(location: 'prince')
      self.location = 'prince'
      state_will_change!
      self.state ||= {}
      self.state[:princed_id] = chosen.id
      save!

      game.histories.create!(event: "#{actor.name} set aside #{chosen} with #{self}.",
                              css_class: "player#{actor.seat}")

      # There's an outside chance that the Prince was itself being Princed. In which case
      # we need to remove the link from the other, Princing, Prince.
      princer = actor.cards.in_location('prince').of_type('PromoCards::Prince').detect { |p| p.state.andand[:princed_id] == id }
      if princer
        princer.state_will_change!
        princer.state.delete :princed_id
        princer.save!
      end
    end

    "OK"
  end

  # If Prince is set aside with another card, play that other card.
  def witness_turn_start(parent_act)
    # Nothing happens unless this Prince is in the "prince" location, and references
    # another card which is also in the "prince" location.
    return unless location == 'prince'
    princed_id = state.andand[:princed_id]
    princed_card = Card.find_by_id(princed_id)
    return unless princed_card.andand.location == 'prince'
    raise "Prince set aside with a non-action card" unless princed_card.is_action?

    # Ok, log and play the Princed card. It expects to be in the hand, like Throne Room, so
    # oblige.
    game.histories.create!(event: "#{player.name}'s #{self} played #{princed_card}.",
                            css_class: "player#{player.seat}#{" play_attack" if princed_card.is_attack?}")
    princed_card.location = 'hand'
    princed_card.play(parent_act)
  end

  def trigger(params)
    # It's the end of the turn. If the Princed card is still in play, set it aside again
    princed_card = Card.find_by_id(state.andand[:princed_id])

    if princed_card.andand.location == 'play'
      # Princed card is still in play - set it aside again.
      #
      # TODO: This assumption breaks with Adventures, in the case of cards leaving and re-entering play.
      princed_card.location = 'prince'
      princed_card.save!
    elsif state.andand[:princed_id] && !(princed_card.andand.location == 'prince')
      # Princed card not found in play (and it isn't already with the Prince, which it will be the very first turn).
      # Sever the link
      state_will_change!
      state.delete :princed_id
      save!
    end

    "OK"
  end
end
