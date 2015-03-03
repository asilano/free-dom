class BaseGame::Chancellor < Card
  costs 3
  action
  card_text "Action (cost: 3) - +2 Cash. You may immediately put your deck into your " +
                        "discard pile."

  def play(parent_act)
    super

    # Easy bit first. Add two cash
    player.add_cash(2)

    # Now, the "discard your deck" step is actually optional, so create a
    # PendingAction to ask.
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                     :text => "Choose whether to discard your deck, with Chancellor")
    act.player = player
    act.game = game
    act.save!

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    controls[:player] += [{:type => :buttons,
                           :action => :resolve,
                           :label => "#{readable_name}:",
                           :params => {:card => "#{self.class}#{id}",
                                        :substep => 'choose'},
                           :options => [{:text => "Discard deck",
                                         :choice => "discard"},
                                        {:text => "Don't discard",
                                         :choice => "keep"}]
                           }]
  end

  resolves(:choose).validating_params_has_any_of(:choice).
                    validating_param_value_in(:choice, 'discard', 'keep').
                    with do
    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "keep"
      # Chose not to discard the deck, so a no-op. Just create a history
      game.histories.create!(:event => "#{actor.name} chose not to discard their deck.",
                            :css_class => "player#{actor.seat}")
    else
      actor.cards.deck(true).each do |card|
        # Move card to discard _without tripping callbacks
        card.update_column(:location, 'discard')
      end

      # And create a history
      game.histories.create!(:event => "#{actor.name} put their deck onto their discard pile.",
                            :css_class => "player#{actor.seat}")
    end

    "OK"
  end
end
