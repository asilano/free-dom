class Hinterlands::Develop < Card
  action
  costs 3
  card_text "Action (cost: 3) - Trash a card from your hand. Gain a card costing exactly 1 more than it and a card costing exactly " +
            "1 less than it, in either order, putting them on top of your deck."

  def play(parent_act)
    super

    if player.cards.hand(true).map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve_trash directly
      return resolve_trash(player, {:card_index => 0}, parent_act)
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} trashed nothing.",
                            :css_class => "player#{player.seat} card_trash")
    else
      # Create a PendingAction to trash a card
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                       :text => "Trash a card with #{self}",
                                       :player => player,
                                       :game => game)
    end

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "trash"
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :text => "Trash",
                          :nil_action => nil,
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "trash"},
                          :cards => [true] * player.cards.hand.size
                         }]
    when "take1"
      valid_piles = game.piles.map do |pile|
        (pile.cost == (params[:trashed_cost].to_i + 1) || pile.cost == (params[:trashed_cost].to_i - 1)) && !pile.empty?
      end
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take (2nd from top)",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take1",
                                        :trashed_cost => params[:trashed_cost]},
                            :piles => valid_piles
                          }]
    when "take2"
      valid_piles = game.piles.map do |pile|
        pile.cost == params[:valid].to_i && !pile.empty?
      end

      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take (top of deck)",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take2",
                                        :trashed_cost => params[:trashed_cost],
                                        :valid => params[:valid]},
                            :piles => valid_piles
                          }]
    end
  end

  resolves(:trash).validating_params_has(:card_index).
                    validating_param_is_card(:card_index, scope: :hand).
                    with do
    # Trash the selected card.
    card = actor.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{actor.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{actor.seat} card_trash")

    # Check whether the player has a real choice to make
    valid_piles = game.piles.map do |pile|
      (pile.cost == trashed_cost + 1 || pile.cost == trashed_cost - 1) && !pile.empty?
    end

    valid_costs = [trashed_cost + 1, trashed_cost - 1].select do |cost|
      game.piles.any? { |pile| pile.cost == cost && !pile.empty? }
    end
    both_directions = valid_costs.length == 2

    if valid_piles.none?
      # No replacements available. Just log
      game.histories.create!(:event => "#{actor.name} couldn't take either replacement card.",
                             :css_class => "player#{actor.seat}")
    elsif valid_piles.one?
      # Exactly one replacement available. Log that the other one wasn't, and call take2 directly
      rc = resolve_take2(actor,
                         {:pile_index => valid_piles.index(true),
                          :trashed_cost => trashed_cost},
                         parent_act)

      if rc =~ /^OK/
        game.histories.create!(:event => "#{actor.name} could only take one replacement card.",
                               :css_class => "player#{actor.seat}")
      end

      return rc
    else
      # Actual choice. Create action to ask. Whether it's the "first" or "second" action depends
      # on whether both directions are possible
      action = 'take1'
      first = 'first '
      valid = ''

      unless both_directions
        action = 'take2'
        first = ''
        valid = ";valid=#{valid_costs[0]}"
      end

      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_#{action};" +
                                                            "trashed_cost=#{trashed_cost}#{valid}",
                                       :text => "Take #{first}replacement card with #{self}",
                                       :player => player,
                                       :game => game)
    end

    "OK"
  end

  # No validation - done by common resolution "take"
  resolves(:take1).with do
    # Call common function to perform the take
    rc, direction = resolve_take(actor, params, parent_act)

    if rc =~ /^OK/
      # Check if an action is needed to take the second card
      trashed_cost = params[:trashed_cost].to_i
      valid = trashed_cost + {:higher => -1, :lower => 1}[direction]

      valid_piles = game.piles.map do |pile|
        (pile.cost == valid) && !pile.empty?
      end

      if valid_piles.none?
        # No replacements available. Just log
        game.histories.create!(:event => "#{actor.name} couldn't take the second replacement card.",
                               :css_class => "player#{actor.seat}")
      elsif valid_piles.one?
        # Exactly one replacement available. Create an action to handle the second take automatically
        # once the first one is done.
        parent_act.queue(:expected_action => "resolve_#{self.class}#{id}_autotake2;" +
                                             "pile_ix=#{valid_piles.index(true)};" +
                                             "trashed_cost=#{trashed_cost};valid=#{valid}",
                         :game => game)
      else
        # Actually have a choice. Create an action to ask the player
        parent_act.queue(:expected_action => "resolve_#{self.class}#{id}_take2;trashed_cost=#{trashed_cost};valid=#{valid}",
                         :text => "Take second replacement card with #{self}",
                         :player => player,
                         :game => game)
      end
    end

    return rc
  end

  # Automatically gain the second card if there was only one choice.
  def autotake2(params)
    resolve_take2(player,
                  {:pile_index => params[:pile_ix].to_i,
                   :trashed_cost => params[:trashed_cost].to_i,
                   :valid => params[:valid].to_i},
                  params[:parent_act])
  end

  # No validation - done by common resolution "take"
  resolves(:take2).with do
    # Call common function to perform the take
    rc, direction = resolve_take(actor, params, parent_act)

    return rc
  end

  resolves(:take).validating_params_has(:trashed_cost).
                  validating_params_has(:pile_index).
                  validating_param_is_pile(:pile_index) do
                    if my{params}.has_key? :valid
                      cost == my{params}[:valid].to_i
                    else
                      cost == my{params}[:trashed_cost].to_i + 1 ||
                      cost == my{params}[:trashed_cost].to_i - 1
                    end
                  end.
                  with do
    # Process the take.
    direction = nil
    trashed_cost = params[:trashed_cost].to_i
    take_pile = game.piles[params[:pile_index].to_i]
    game.histories.create!(:event => "#{actor.name} took " +
           "#{take_pile.card_class.readable_name} with #{self}.",
                          :css_class => "player#{actor.seat} card_gain")
    actor.gain(parent_act, :pile => take_pile, :location => "deck")

    direction = take_pile.cost > trashed_cost ? :higher : :lower

    return "OK", direction
  end
end