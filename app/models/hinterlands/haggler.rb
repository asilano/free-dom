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

  def resolve_take(ply, params, parent_act)
    # Copied from Expand
    # We expect to have been passed a :pile_index
    if !params.include?(:pile_index)
      return "Invalid parameters"
    end
    original_cost = params[:cost].to_i

    # Processing is pretty much the same as a buy
    if ((params.include? :pile_index) &&
           (params[:pile_index].to_i < 0 ||
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to take an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (params.include? :pile_index) &&
          !(game.piles[params[:pile_index].to_i].cost < original_cost)
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index]].card_type} is too expensive"
    elsif (!params.include? :pile_index) &&
          (game.piles.map do |pile|
              (pile.cost < original_cost) && !pile.empty? && !pile.card_class.is_victory?
           end.any?)
      # Asked to take nothing when there were cards to take
      return "Invalid request - asked to take nothing, but viable options exist"
    end


    if params.include? :pile_index
      # Process the take.
      game.histories.create!(:event => "#{ply.name} took " +
             "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with #{self}.",
                            :css_class => "player#{ply.seat} card_gain")

      ply.gain(parent_act, :pile => game.piles[params[:pile_index].to_i])
    end

    return "OK"
  end

end