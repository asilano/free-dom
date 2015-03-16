class BaseGame::Workshop < Card
  costs 3
  action
  card_text "Action (cost: 3) - Gain a card costing up to 4."

  def play(parent_act)
    super
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take",
                                     :text => "Take a card with Workshop",
                                     :player => player,
                                     :game => game)

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    controls[:piles] += [{:type => :button,
                          :action => :resolve,
                          :text => "Take",
                          :nil_action => nil,
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => 'take'},
                          :piles => game.piles.map do |pile|
                            pile.cost <= 4 and not pile.empty?
                          end
                        }]
  end

  resolves(:take).validating_params_has(:pile_index).
                 validating_param_is_pile(:pile_index) { cost <= 4 }.
                 with do
    # Process the take. Move the chosen card to the top of the discard pile
    # Get the card to do it, so that we mint a fresh instance of infinite cards
    game.histories.create!(:event => "#{actor.name} took " +
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} from the Workshop.",
                          :css_class => "player#{actor.seat} card_gain")

    actor.gain(parent_act, :pile => game.piles[params[:pile_index].to_i])

    "OK"
  end

end
