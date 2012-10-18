# Forge (Action - $7) - Trash any number of cards from your hand. Gain a card with cost exactly equal to the total cash cost of the trashed cards.

class Prosperity::Forge < Card
  action
  costs 7
  card_text "Action (cost: 7) - Trash any number of cards from your hand. Gain a card with cost exactly equal to the total cash cost of the trashed cards."

  def play(parent_act)
    super

    if player.cards.hand(true).empty?
      # No cards in hand. Just call resolve_trash with no card indices.
      resolve_trash(player, {}, parent_act)
    else
      # Add an action to ask for forge material
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                 :text => "Trash cards from hand with #{readable_name}.",
                                 :game => game,
                                 :player => player)
    end

    return "OK"
  end

  def determine_controls(ply, controls, substep, params)
    case substep
    when "trash"
      controls[:hand] += [{:type => :checkboxes,
                           :action => :resolve,
                           :name => "trash",
                           :choice_text => "Trash",
                           :button_text => "Trash selected",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "trash"},
                           :cards => [true] * player.cards.hand.size,
                           :data => player.cards.hand.map {|c| c.cost},
                           :on_update => :forge_calc,
                           :on_update_initial => "Total: 0"
                          }]
    when "take"
      valid_piles = game.piles.map do |pile|
        (pile.cost == (params[:trashed_cost].to_i)) && !pile.empty?
      end
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take",
                            :nil_action => valid_piles.any? ? nil : "Take nothing",
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take",
                                        :trashed_cost => params[:trashed_cost]},
                            :piles => valid_piles
                          }]
    end
  end

  def resolve_trash(ply, params, parent_act)
    # The player can choose to trash nothing; if a :trash paramter is
    # present, we expect each entry to be a valid card index.
    if (params.include? :trash and
        params[:trash].any? {|d| d.to_i < 0 or d.to_i >= ply.cards.hand.size})
      return "Invalid parameters - at least one card index out of range"
    end

    # Looks good.
    cost = 0
    if not params.include? :trash
      # Create a log. Cost is already correct
      game.histories.create!(:event => "#{ply.name} trashed no cards with #{readable_name} (total cost: 0).",
                            :css_class => "player#{ply.seat} card_trash")
    else
      # Trash each selected card, taking note of its class for logging purposes, and adding its cost to the running total
      cards_trashed = []
      cards_chosen = params[:trash].map {|ix| ply.cards.hand[ix.to_i]}
      cards_chosen.each do |card|
        card.trash
        cards_trashed << card.class.readable_name
        cost += card.cost
      end

      # Log the trashes
      game.histories.create!(:event => "#{ply.name} trashed #{cards_trashed.join(', ')} with #{readable_name} (total cost: #{cost}).",
                            :css_class => "player#{ply.seat} card_trash")
    end

    # Finally, handle picking up a replacement.
    valid_piles = game.piles.select do |pile|
      (pile.cost == cost) && !pile.empty?
    end

    if valid_piles.length == 1
      # Only one possibility for a replacement; take it automatically
      game.histories.create!(:event => "#{ply.name} took " +
           "#{valid_piles[0].card_class.readable_name} with Forge.",
                          :css_class => "player#{ply.seat} card_gain")

      ply.gain(parent_act, valid_piles[0].id)
    elsif valid_piles.length == 0
      # No possible replacements
      game.histories.create!(:event => "#{ply.name} was unable to take a card costing #{cost}.",
                            :css_class => "player#{ply.seat}")
    else
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{cost}",
                                 :text => "Take a replacement card costing #{cost} with #{readable_name}.",
                                 :game => game,
                                 :player => player)
    end

    return "OK"

  end

  def resolve_take(ply, params, parent_act)
    # We expect to have been passed a :pile_index
    if !params.include? :pile_index
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    if ((params[:pile_index].to_i < 0 ||
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to take an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (game.piles[params[:pile_index].to_i].cost != (params[:trashed_cost].to_i))
      # Asked to take an invalid card (wrong cost)
      return "Invalid request - card #{game.piles[params[:pile_index]].card_type} doesn't cost #{params[:trashed_cost]}"
    end

    game.histories.create!(:event => "#{ply.name} took " +
            "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with #{readable_name}.",
                          :css_class => "player#{ply.seat} card_gain")

    ply.gain(parent_act, game.piles[params[:pile_index].to_i].id)

    return "OK"
  end
end