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

    return "OK"
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
        pile.cost == params[:valid].to_i
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

  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include?(:card_index)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to trash an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"

    end

    # All checks out. Carry on

    # Trash the selected card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{ply.seat} card_trash")

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
      game.histories.create!(:event => "#{ply.name} couldn't take either replacement card.",
                             :css_class => "player#{ply.seat}")
    elsif valid_piles.one?
      # Exactly one replacement available. Log that the other one wasn't, and call take2 directly
      rc = resolve_take2(ply,
                         {:pile_index => valid_piles.index(true),
                          :trashed_cost => trashed_cost},
                         parent_act)

      if rc =~ /^OK/
        game.histories.create!(:event => "#{ply.name} could only take one replacement card.",
                               :css_class => "player#{ply.seat}")
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

    return "OK"
  end

  def resolve_take1(ply, params, parent_act)
    # Call common function to perform the take
    rc, direction = take(ply, params, parent_act)

    if rc =~ /^OK/
      # Check if an action is needed to take the second card
      trashed_cost = params[:trashed_cost].to_i
      valid = trashed_cost + {:higher => -1, :lower => 1}[direction]

      valid_piles = game.piles.map do |pile|
        (pile.cost == valid) && !pile.empty?
      end

      if valid_piles.none?
        # No replacements available. Just log
        game.histories.create!(:event => "#{ply.name} couldn't take the second replacement card.",
                               :css_class => "player#{ply.seat}")
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

  def resolve_take2(ply, params, parent_act)
    # Call common function to perform the take
    rc, direction = take(ply, params, parent_act)

    return rc
  end

  def take(ply, params, parent_act)
    # We expect to have been passed a :pile_index or :nil_action
    if !params.include?(:pile_index) && !params.include?(:nil_action)
      return "Invalid parameters"
    end

    # Define the set of valid costs (it's either both sides of the trashed cost,
    # or just one side if one take has already happened)
    trashed_cost = params[:trashed_cost].to_i
    if params.include?(:valid)
      valid_costs = [params[:valid].to_i]
    else
      valid_costs = [trashed_cost - 1, trashed_cost + 1]
    end

    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    if ((params.include? :pile_index) &&
           (params[:pile_index].to_i < 0 ||
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to take an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (params.include? :pile_index) &&
          !(valid_costs.include?(game.piles[params[:pile_index].to_i].cost))
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index].to_i].card_type} is the wrong cost"
    elsif (!params.include? :pile_index) &&
          (game.piles.any? do |pile|
              (valid_costs.include?(pile.cost)) && !pile.empty?
           end)
      # Asked to take nothing when there were cards to take
      return "Invalid request - asked to take nothing, but viable replacements exist"
    end

    direction = nil
    if params.include? :pile_index
      # Process the take.
      take_pile = game.piles[params[:pile_index].to_i]
      game.histories.create!(:event => "#{ply.name} took " +
             "#{take_pile.card_class.readable_name} with #{self}.",
                            :css_class => "player#{ply.seat} card_gain")
      ply.gain(parent_act, :pile => take_pile, :location => "deck")

      direction = take_pile.cost > trashed_cost ? :higher : :lower
    else
      # Create a history
      game.histories.create!(:event => "#{ply.name} couldn't take a replacement.",
                            :css_class => "player#{ply.seat} card_gain")
    end

    return "OK", direction
  end
end