class BaseGame::Feast < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash this card. Gain a card costing up to 5."

  def play(parent_act)
    super

    # First create a PendingAction to take a replacement.
    # We do this first, since we still have a Player here
    #
    # Note that Feast doesn't care whether the trash succeeded when gaining
    # the replacement.
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take",
                               :text => "Take a card with Feast",
                               :player => player,
                               :game => game)

    # Now move this card to Trash
    trash

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "take"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take"},
                            :piles => game.piles.map do |pile|
                              pile.cost <= 5 && !pile.empty?
                            end
                          }]
    end
  end

  resolves(:take).validating_params_has_any_of(:pile_index).
                 validating_param_is_pile(:pile_index) { |pile| pile.cost <= 5 }.
                 with do
    # Process the take.
    game.histories.create!(:event => "#{actor.name} took " +
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with Feast.",
                          :css_class => "player#{actor.seat} card_gain")

    actor.gain(parent_act, :pile => game.piles[params[:pile_index].to_i])

    return "OK"
  end
end
