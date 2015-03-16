class Hinterlands::Haggler < Card
  action
  costs 5
  card_text "Action (costs: 5) - +2 Cash. / While this is in play, when you buy a card, " +
            "gain a card costing less than it that is not a Victory card."

  def play(parent_act)
    super

    player.add_cash(2)
    "OK"
  end

  # Notice a buy event. If Haggler's in play, queue up an action to take another card.
  def self.witness_buy(params)
    ply = params[:buyer]
    pile = params[:pile]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether any Haggler cards are in play for the buyer, and if so queue to choose another card to take
    hagglers = ply.cards.in_play.of_type("#{self}")
    if !hagglers.empty?
      # Check that there are any possible alternatives to take!
      valid_piles = game.piles.select do |pile2|
                       (pile2.cost < pile.cost) && !pile2.empty? && !pile2.card_class.is_victory?
                    end

      if valid_piles.empty?
        # Most likely the bought card costs 0.
        # Create a history that there were no options
        game.histories.create!(:event => "#{ply.name} couldn't take another card with #{readable_name}.",
                               :css_class => "player#{ply.seat} card_gain")
      elsif valid_piles.one?
        # Just gain the only possible option
        game.histories.create!(:event => "#{ply.name} took " +
                                         "#{valid_piles[0].card_class.readable_name} with #{readable_name}.",
                               :css_class => "player#{ply.seat} card_gain")

        ply.gain(parent_act, :pile => valid_piles[0])
      else
        # Queue up to choose another card to take
        hagglers.each do |card|
          parent_act.children.create!(:expected_action => "resolve_#{self}#{card.id}_take;cost=#{pile.cost}",
                                      :text => "Choose a card to gain with Haggler",
                                      :player => ply,
                                      :game => game)
        end
      end
    end

    # Adding the extra gain does not affect the Buy of the original card in any way.
    return false
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "take"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take",
                                        :cost => params[:cost]},
                            :piles => game.piles.map do |pile|
                              pile.cost < params[:cost].to_i && !pile.empty? && !pile.card_class.is_victory?
                            end
                          }]
    end
  end

  resolves(:take).validating_params_has(:pile_index).
                  validating_params_has(:cost).
                  validating_param_is_pile(:pile_index) { cost < my{params}[:cost].to_i && !card_class.is_victory?}.
                  with do
    # Process the take.
    game.histories.create!(:event => "#{actor.name} took " +
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with #{self}.",
                          :css_class => "player#{actor.seat} card_gain")

    actor.gain(parent_act, :pile => game.piles[params[:pile_index].to_i])

    "OK"
  end

end