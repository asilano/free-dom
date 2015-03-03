class BaseGame::Chapel < Card
  costs 2
  action
  card_text "Action (cost: 2) - Trash up to 4 cards from your hand."

  def play(parent_act)
    super

    # Queue up four actions to Trash a card (the player will be able to get out
    # with the nil_action at any point)
    1.upto(4) do |n|
      parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                              :text => "Trash up to #{n} card#{n != 1 ? 's' : ''} with Chapel")
      parent_act.player = player
      parent_act.game = game
      parent_act.save!
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "trash"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :text => "Trash",
                          :nil_action => "Trash no more",
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "trash"},
                          :cards => [true] * player.cards.hand.size
                         }]
    end
  end

  resolves(:trash).validating_params_has_any_of(:nil_action, :card_index).
                   validating_param_is_card(:card_index, scope: :hand).
                   with do
    # All checks out. Carry on
    if params.include? :nil_action
      # Player has chosen to "Trash no more". Destroy any remaining Trash
      # actions above here.
      game.histories.create!(:event => "#{actor.name} stopped trashing.",
                            :css_class => "player#{actor.seat} card_trash")
      local_act = parent_act
      until local_act.expected_action != "resolve_#{self.class}#{id}_trash"
        act = local_act
        local_act = local_act.parent
        act.destroy
      end

      Game.current_act_parent = local_act
    else
      # Trash the selected card
      card = actor.cards.hand[params[:card_index].to_i]
      card.trash
      game.histories.create!(:event => "#{actor.name} trashed a #{card.class.readable_name} from hand.",
                            :css_class => "player#{actor.seat} card_trash")
    end

    "OK"
  end
end
