class Intrigue::Minion < Card
  costs 5
  action :attack => true
  card_text "Action (Attack; cost: 5) - +1 Action. Choose one: +2 cash; or " +
            "discard your hand and draw 4 cards, and each other player with 5 or " +
            "more cards in hand discards his hand and draws 4."

  def play(parent_act)
    super

    # Grant an additional action after the rest of the effects
    parent_act = player.add_actions(1, parent_act)

    # Curiously enough, all the rulings I've been able to find indicate that
    # Minion is an attack regardless of which mode it's in. However, since
    # Reacting is just Something You Can Do, rather than a "triggered ability",
    # we should find which mode we're in before we ask for reactions.
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                               :text => "Choose Minion mode",
                               :player => player,
                               :game => game)

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    case substep
    when "choose"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :label => readable_name + " mode:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"},
                             :options => [{:text => "+2 Cash",
                                           :choice => "cash"},
                                          {:text => "Cycle hands",
                                           :choice => "cycle"}]
                            }]
    end
  end

  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, either "cash" or "cycle"
    if (not params.include? :choice) or
       (not params[:choice].in? ["cash", "cycle"])
      return "Invalid parameters"
    end

    # All looks fine, process the choice
    if params[:choice] == "cash"
      # Nice Minion. Grant the cash, write the history, set up the param
      ply.add_cash(2)
      game.histories.create!(:event => "#{ply.name} chose to take 2 cash from the Minion.",
                            :css_class => "player#{ply.seat}")
      attack_type = "nice"
    else
      # Nasty Minion. Write the history and set up the param, then cycle this
      # player's cards.
      game.histories.create!(:event => "#{ply.name} chose to cycle hands with the Minion.",
                            :css_class => "player#{ply.seat}")
      attack_type = "nasty"
      game.histories.create!(:event => "#{ply.name} discarded their hand.",
                            :css_class => "player#{ply.seat} card_discard")

      # Queue up the draw action in case discarding causes anything to trigger
      # (such as, Hinterlands::Tunnel)
      Game.parent_act = parent_act.children.create!(
              :expected_action => "resolve_#{self.class}#{id}_draw_4;tgt=#{player.id}",
              :game => game)

      ply.cards.hand(true).each do |card|
        card.discard
      end
    end

    # Create the attack framework
    attack(parent_act, :attack_type => attack_type)

    return "OK"
  end

  def draw_4(params)
    target = Player.find(params[:tgt])
    target.draw_cards(4)
  end

  def attackeffect(params)
    # Golden path - the attack is a no-op in "nice" mode
    if params[:attack_type] == "nice"
      return "OK"
    end

    raise "Invalid attack type" unless params[:attack_type] == "nasty"

    # Effect of the attack succeeding - that is, check whether the target has
    # at least 5 cards in hand, then discarding and drawing 4 if so.
    target = Player.find(params[:target])
    parent_act = params[:parent_act]


    if target.cards.hand(true).length > 4
      # Queue up the draw action in case discarding causes anything to trigger
      # (such as Hinterlands::Tunnel)
      Game.parent_act = parent_act.children.create!(
              :expected_action => "resolve_#{self.class}#{id}_draw_4;tgt=#{target.id}",
              :game => game)

      target.cards.hand.each do |card|
        card.discard
      end

      game.histories.create!(:event => "#{target.name} discarded their hand.",
                            :css_class => "player#{target.seat} card_discard")
    else
      game.histories.create!(:event => "#{target.name} had #{target.cards.hand.length} cards, and was unaffected by Minion.",
                            :css_class => "player#{target.seat}")
    end

    return "OK"
  end
end
