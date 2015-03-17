class Hinterlands::Oracle < Card
  action :attack => true, :affects_attacker => true
  costs 3
  card_text "Action (Attack; cost: 3) - Each player (including you) reveals the top 2 cards of his deck, " +
            "and you choose one: either he discards them, or he puts them back on top in an order he chooses. Draw 2 cards."

  def play(parent_act)
    super

    # Queue up an action, once the attack has finished, to draw the owner two cards
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_drawtwo",
                                      :game => game)

    attack(act)

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "choose"
      ctrl = {:type => :buttons,
               :action => :resolve,
               :label => "#{self} effect:",
               :params => {:card => "#{self.class}#{id}",
                           :substep => "choose",
                           :target => params[:target]},
               :options => [{:text => "Put back",
                             :choice => "replace"},
                            {:text => "Discard",
                             :choice => "discard"}]
              }

      if (params[:target].to_i == player.id)
        controls[:player] += [ctrl]
      else
        controls[:other_players] += [ctrl.merge(:player_id => params[:target])]
      end
    when "place"
      controls[:revealed] += [{:player_id => player.id,
                               :type => :button,
                               :action => :resolve,
                               :text => "Place #{ActiveSupport::Inflector.ordinalize(params[:posn])}",
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "place",
                                           :posn => params[:posn]},
                               :cards => [true] * player.cards.revealed.length
                              }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, reveal the top two cards, and
    # ask the attacker to choose Put back or Discard.
    target = Player.find(params[:target])
    source = Player.find(params[:source])
    parent_act = params[:parent_act]

    revealed = target.reveal_from_deck(2)

    # Assuming something was actually revealed, ask the attacker if they should be put
    # back or not.
    if !revealed.empty?
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose;target=#{target.id}",
                                  :text => "Choose Oracle effect for #{target.name}'s revealed cards",
                                  :game => game,
                                  :player => source)
    end

    return "OK"
  end

  resolves(:choose).validating_params_has(:choice).
                    validating_param_value_in(:choice, 'discard', 'replace').
                    validating_params_has(:target).
                    validating_param_is_player(:target).
                    with do
    target = Player.find(params[:target])

    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "replace"
      # Chose not to discard the target's revealed cards. Create a history
      revealed_names = target.cards.revealed.join(' and ')
      game.histories.create!(:event => "#{actor.name} chose not to discard #{target.name}'s revealed #{revealed_names}.",
                             :css_class => "player#{actor.seat} player#{target.seat}")

      raise "Nothing revealed to #{self.class}" if target.cards.revealed.empty?
      raise "More than 2 cards revealed to #{self.class}" if target.cards.revealed.length > 2

      if target.cards.revealed.length == 1
        # Only one card - it has to go on top. In fact, it already is, so just log and unreveal it.
        card = target.cards.revealed[0]
        game.histories.create!(:event => "#{target.name} placed #{card} on top of their deck.",
                               :css_class => "player#{target.seat}")
        card.revealed = false
        card.save!
      elsif target.settings.autooracle
        # Target has autooracle on, so the cards can just go back in the same order.
        # Easiest way to do this - and ensure the logs are right - is to call resolve_place
        # directly, with the correct card index.
        ix = target.cards.revealed.index(target.cards.deck[1])
        resolve_place(target, {:card_index => ix, :posn => 2}, parent_act)
      else
        # Create pending actions to put the remaining cards back in any
        # order. We don't need an action for the last one.
        #
        # We expect there to be exactly 2 cards revealed. 0 would be a possibility,
        # except _attackeffect_ rules it out; but we'll cope for robustness.
        if target.cards.revealed.present?
          raise "Unexpected number of revealed cards (got #{target.cards.revealed.length}, expected 0-2) in #{self}" unless target.cards.revealed.length == 2
          parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_place;posn=2",
                                      :text => "Put a card 2nd from top with #{readable_name}",
                                      :player => target,
                                      :game => game)
        end
      end
    else
      # Chose to discard the target's cards. Create a history
      revealed_cards = target.cards.revealed
      game.histories.create!(:event => "#{actor.name} chose to discard #{target.name}'s revealed #{revealed_cards.join(' and ')}.",
                             :css_class => "player#{actor.seat} player#{target.seat}")

      # And discard them
      revealed_cards.each do |cd|
        cd.discard
      end
    end

    "OK"
  end

  resolves(:place).validating_params_has(:card_index).
                    validating_param_is_card(:card_index, scope: :revealed).
                    with do
    # All checks out. Place the selected card on top of the deck (position -1),
    # unreveal it, and renumber.
    card = actor.cards.revealed[params[:card_index].to_i]
    card.location = "deck"
    card.position = -1
    card.revealed = false
    card.save!
    game.histories.create!(:event => "#{actor.name} placed [#{actor.id}?#{card.class.readable_name}|a card] #{ActiveSupport::Inflector.ordinalize(params[:posn])} from top.",
                           :css_class => "player#{actor.seat}")

    if params[:posn].to_i == 2
      # That was the card second from top, so only one card remains to be placed. Do so.
      raise "Wrong number of revealed cards" unless actor.cards.revealed(true).count == 1
      card = actor.cards.revealed[0]
      card.location = "deck"
      card.position = -2
      card.revealed = false
      card.save!
      game.histories.create!(:event => "#{actor.name} placed [#{actor.id}?#{card.class.readable_name}|a card] on top of their deck.",
                             :css_class => "player#{actor.seat}")
    end

    "OK"
  end

  def drawtwo(params)
    # Callback for owner to draw two cards
    player.draw_cards(2)
  end
end