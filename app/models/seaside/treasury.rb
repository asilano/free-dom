# 25  Treasury  Seaside  Action  $5  +1 Card, +1 Action, +1 Coin, When you discard this from play, if you didn't buy a Victory card this turn, you may put this on top of your deck.

class Seaside::Treasury < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw 1 card, +1 Action, +1 Cash. When you discard this from play, if you didn't buy a Victory card this turn, you may put this on top of your deck."

  serialize :state, Hash

  trigger :handle_on_discard, :on => {:location => ['play', 'discard']}

  def play(parent_act)
    super

    # First, draw the cards.
    player.draw_cards(1)

    # Now create the new Action
    player.add_actions(1, parent_act)

    # And add the coin
    player.add_cash(1)

    return "OK"
  end

  def handle_on_discard
    parent_act = Game.parent_act

    if (state && state[:skip_callback])
      # Let the discard happen, and clear the state for next time around
      self.state[:skip_callback] = false
    elsif (!player.state.bought_victory)
      # Player bought no victory card this turn. Ask them where they want the Treasury.
      # Hang the action to do so off parent_act, which can't be nil
      raise "Need a non-nil parent act" if parent_act.nil?

      if player.settings.autotreasury
        # Player has chosen to always put Treasuries on top when allowed
        return resolve_replace(player, {:choice => 'deck'}, parent_act)
      else
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_replace",
                                   :text => "Choose where to place #{readable_name}",
                                   :player => player,
                                   :game => game)
      end

      # Prevent this set of changes from happening
      changed.each {|att| method("reset_#{att}!").call}
    else
      # Player did buy a victory this turn. Let the discard happen.
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "replace"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :label => "Move #{readable_name}:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "replace"},
                             :options => [{:text => "Top of deck",
                                           :choice => "deck"},
                                          {:text => "Discard",
                                           :choice => "discard"}]
                            }]
    end
  end

  def resolve_replace(ply, params, parent_act)
    # We expect to have a :choice parameter, either "deck" or "discard"
    if (not params.include? :choice) or
       (not params[:choice].in? ["deck", "discard"])
      return "Invalid parameters"
    end

    # All looks fine, process the choice
    if params[:choice] == "deck"
      # Return this card to the top of the deck
      player.cards.deck(true) << self
      self.location = "deck"
      self.position = -1
      save!

      game.histories.create!(:event => "#{ply.name} chose to put their #{readable_name} on top of their deck.",
                            :css_class => "player#{ply.seat}")
    else
      # Just discard the card, noting that we shouldn't enter an infinite loop
      self.state ||= {}
      self.state[:skip_callback] = true
      discard

      game.histories.create!(:event => "#{ply.name} chose to put their #{readable_name} into their discard.",
                            :css_class => "player#{ply.seat}")
    end

    return "OK"
  end

end

