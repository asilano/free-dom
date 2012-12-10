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
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}",
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
                           :params => {:card => "#{self.class}#{id}"},
                           :options => [{:text => "Discard deck",
                                         :choice => "discard"},
                                        {:text => "Don't discard",
                                         :choice => "keep"}]
                           }]
  end

  def resolve(ply, params, parent_act)
    # We expect to have a :choice parameter, either "discard" or "keep"
    if (not params.include? :choice) or
       (not params[:choice].in? ["discard", "keep"])
      return "Invalid parameters"
    end

    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "keep"
      # Chose not to discard the deck, so a no-op. Just create a history
      game.histories.create!(:event => "#{ply.name} chose not to discard their deck.",
                            :css_class => "player#{ply.seat}")
    else
      ply.cards.deck(true).each do |card|
        card.discard
      end

      # And create a history
      game.histories.create!(:event => "#{ply.name} put their deck onto their discard pile.",
                            :css_class => "player#{ply.seat}")
    end

    return "OK"
  end
end
