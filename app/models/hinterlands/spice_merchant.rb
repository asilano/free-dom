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

  resolves(:trash).validating_params_has_any_of(:nil_action, :card_index).
                    validating_param_is_card(:card_index, scope: :hand, &:is_treasure?).
                    with do
    if params.include? :nil_action
      game.histories.create!(:event => "#{actor.name} trashed nothing.",
                            :css_class => "player#{actor.seat}")
    else
      card = actor.cards.hand[params[:card_index].to_i]

      # Trash the treasure
      card.trash
      game.histories.create!(:event => "#{actor.name} trashed a #{card} from hand.",
                             :css_class => "player#{actor.seat} card_trash")

      # And queue up a request to ask which type of benefit they want
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                  :text => "Choose #{self}'s benefit",
                                  :game => game,
                                  :player => player)
    end

    "OK"
  end

  # We expect to have a :choice parameter, "cards_act" or "cashbuy"
  resolves(:choose).validating_params_has(:choice).
                    validating_param_value_in(:choice, 'cardsact', 'cashbuy').
                    with do
    # Everything looks fine. Carry out the requested choice
    if (params[:choice] == "cardsact")
      # Chose cards and action. Log and grant them
      game.histories.create(:event => "#{actor.name} chose to draw 2 and gain an Action.",
                            :css_class => "player#{actor.seat}")
      actor.draw_cards(2)
      actor.add_actions(1, parent_act)
    else
      # Chose cash and buy. Log and grant them
      game.histories.create(:event => "#{actor.name} chose to gain 2 Cash and a Buy.",
                            :css_class => "player#{actor.seat}")
      actor.add_cash(2)
      actor.add_buys(1, parent_act)
    end

    "OK"
  end

end