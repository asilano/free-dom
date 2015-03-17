# BorderVillage (Action - $6) - Draw 1 card, +2 Actions. / When you gain this, gain a card costing less than this.

class Hinterlands::BorderVillage < Card
  action
  costs 6
  card_text "Action (cost: 6) - Draw 1 card, +2 Actions. / When you gain this, gain a card costing less than this."

  def play(parent_act)
    super

    player.draw_cards(1)
    player.add_actions(2, parent_act)

    "OK"
  end

  # Notice a gain event. If it's Border Village itself, queue up an action to take another card.
  def self.witness_gain(params)
    ply = params[:gainer]
    card = params[:card]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card gained is Border Village, and if so queue to choose another card to take
    if card.class == self
      # Check that there are any possible alternatives to take!
      valid_piles = game.piles.select do |pile2|
                       (pile2.cost < card.cost) && !pile2.empty?
                    end
      if valid_piles.empty?
        # Most likely Border Village costs 0.
        # Create a history that there were no options
        game.histories.create!(:event => "#{ply.name} couldn't take another card with #{self}.",
                              :css_class => "player#{ply.seat} card_gain")
      elsif valid_piles.one?
        # Just gain the only possible option
        game.histories.create!(:event => "#{ply.name} took " +
             "#{valid_piles[0].card_class.readable_name} with #{self}.",
                            :css_class => "player#{ply.seat} card_gain")

        ply.gain(parent_act, :pile => valid_piles[0])
      else
        # Queue up to choose another card to take
        parent_act.children.create!(:expected_action => "resolve_#{self}#{card.id}_take",
                                    :text => "Choose a card to gain with #{self}",
                                    :player => ply,
                                    :game => game)
      end
    end

    # Adding the extra gain does not affect the gain of Border Village itself in any way.
    return false
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "take"
      border_village_pile = game.piles.find_by_card_type("Hinterlands::BorderVillage")
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take"},
                            :piles => game.piles.map do |pile|
                              pile.cost < border_village_pile.cost && !pile.empty?
                            end
                          }]
    end
  end

  resolves(:take).validating_params_has(:pile_index).
                  validating_param_is_pile(:pile_index) { cost < my{game}.piles.find_by_card_type("Hinterlands::BorderVillage").cost }.
                  with do
    # Process the take.
    game.histories.create!(:event => "#{actor.name} took " +
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with #{self}.",
                          :css_class => "player#{actor.seat} card_gain")

    actor.gain(parent_act, :pile => game.piles[params[:pile_index].to_i])

    "OK"
  end
end