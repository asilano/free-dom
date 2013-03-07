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
    pile = params[:pile]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card gained is Border Village, and if so queue to choose another card to take
    if pile.card_class == self
      # Check that there are any possible alternatives to take!
      valid_piles = game.piles.select do |pile2|
                       (pile2.cost < pile.cost) && !pile2.empty?
                    end
      if valid_piles.empty?
        # Most likely Border Village costs 0.
        # Create a history that there were no options
        game.histories.create!(:event => "#{ply.name} couldn't take another card with Border Village.",
                              :css_class => "player#{ply.seat} card_gain")
      elsif valid_piles.one?
        # Just gain the only possible option
        game.histories.create!(:event => "#{ply.name} took " +
             "#{valid_piles[0].card_class.readable_name} with Border Village.",
                            :css_class => "player#{ply.seat} card_gain")

        ply.gain(parent_act, valid_piles[0].id)
      else
        # Queue up to choose another card to take
        parent_act.children.create!(:expected_action => "resolve_#{self}#{pile.cards[0].id}_take",
                                    :text => "Choose a card to gain with Border Village",
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

  def resolve_take(ply, params, parent_act)
    # Copied from Expand
    # We expect to have been passed a :pile_index
    if !params.include?(:pile_index)
      return "Invalid parameters"
    end
    border_village_pile = game.piles.find_by_card_type("Hinterlands::BorderVillage")

    # Processing is pretty much the same as a buy
    if ((params.include? :pile_index) &&
           (params[:pile_index].to_i < 0 ||
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to take an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (params.include? :pile_index) &&
          !(game.piles[params[:pile_index].to_i].cost < border_village_pile.cost)
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index]].card_type} is too expensive"
    elsif (not params.include? :pile_index) &&
          (game.piles.map do |pile|
              (pile.cost < border_village_pile.cost) && !pile.empty?
           end.any?)
      # Asked to take nothing when there were cards to take
      return "Invalid request - asked to take nothing, but viable options exist"
    end


    if params.include? :pile_index
      # Process the take.
      game.histories.create!(:event => "#{ply.name} took " +
             "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with Border Village.",
                            :css_class => "player#{ply.seat} card_gain")

      ply.gain(parent_act, game.piles[params[:pile_index].to_i].id)
    end

    return "OK"
  end
end