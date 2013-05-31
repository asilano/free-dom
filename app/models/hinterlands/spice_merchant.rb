class Hinterlands::SpiceMerchant < Card
  action
  costs 4
  card_text "Action (cost: 4) - You may trash a Treasure from your hand. If you do, choose one: " +
            "Draw 2 cards, +1 Action; or +2 cash, +1 Buy"

  def play(parent_act)
    super

    if (player.cards.hand.none? &:is_treasure?)
      # Can't trash a treasure - not holding any. Call resolve to ensure the
      # logs match.
      resolve_trash(player, {:nil_action => true}, parent_act)
    else
      # Ask the player which treasure to trash
      parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}_trash",
                                 :text => "Trash a Treasure card with Spice Merchant",
                                 :game => game,
                                 :player => player)
    end

    return "OK"
  end

  def determine_controls(ply, controls, substep, params)
    case substep
    when "trash"
      controls[:hand] += [{:type => :button,
                           :text => "Trash",
                           :nil_action => "Trash nothing",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "trash"},
                           :cards => player.cards.hand.map {|c| c.is_treasure?}
                         }]
    when "choose"
      controls[:player] += [{:type => :buttons,
                             :label => "#{readable_name} benefit:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"},
                             :options => [{:text => "2 Cards, 1 Action",
                                           :choice => "cardsact"},
                                          {:text => "2 Cash, 1 Buy",
                                           :choice => "cashbuy"}]
                           }]
    end
  end

  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to trash an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Carry on
    if params.include? :nil_action
      game.histories.create!(:event => "#{ply.name} trashed nothing.",
                            :css_class => "player#{ply.seat}")
    else
      card = ply.cards.hand[params[:card_index].to_i]
      if !(card.andand.is_treasure?)
        # Asked to trash a non-treasure
        return "Invalid request - #{card.readable_name} is not a Treasure"
      end

      # Trash the treasure
      card.trash

      # And queue up a request to ask which type of benefit they want
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                  :text => "Choose #{self}'s benefit",
                                  :game => game,
                                  :player => player)
    end

    return "OK"
  end

  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, "cards_act" or "cashbuy"
    if (!params.include? :choice) ||
       (!params[:choice].in? ["cardsact","cashbuy"])
      return "Invalid parameters"
    end

    # Everything looks fine. Carry out the requested choice
    if (params[:choice] == "cardsact")
      # Chose cards and action. Log and grant them
      game.histories.create(:event => "#{ply.name} chose to draw 2 and gain an Action.",
                            :css_class => "#{ply.seat}")
      ply.draw_cards(2)
      ply.add_actions(1, parent_act)
    else
      # Chose cash and buy. Log and grant them
      game.histories.create(:event => "#{ply.name} chose to gain 2 Cash and a Buy.",
                            :css_class => "#{ply.seat}")
      ply.add_cash(2)
      ply.add_buys(1, parent_act)
    end

    return "OK"
  end

end