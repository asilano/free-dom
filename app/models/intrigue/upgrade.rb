class Intrigue::Upgrade < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw 1 card, +1 Action. " +
            "Trash a card from your hand. Gain a card costing exactly 1 more than it."

  def play(parent_act)
    super

    player.draw_cards(1)
    parent_act = player.add_actions(1, parent_act)

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
                                       :text => "Upgrade a card",
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
    when "take"
      valid_piles = game.piles.map do |pile|
        (pile.cost == (params[:trashed_cost].to_i + 1)) and not pile.empty?
      end
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take",
                                        :trashed_cost => params[:trashed_cost]},
                            :piles => valid_piles
                          }]
    end
  end

  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include? :card_index
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

    # Trash the selected card. and create a new PendingAction for picking up
    # the remodelled card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost

    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{ply.seat} card_trash")

    valid_piles = game.piles.select do |pile|
      (pile.cost == (trashed_cost + 1)) && !pile.empty?
    end

    if valid_piles.length == 1
      # Only one possibility for a replacement; take it automatically
      game.histories.create!(:event => "#{ply.name} took " +
           "#{valid_piles[0].card_class.readable_name} with Upgrade.",
                          :css_class => "player#{ply.seat} card_gain")

      ply.gain(parent_act, valid_piles[0].id)
    elsif valid_piles.length == 0
      # No possible replacements
      game.histories.create!(:event => "#{ply.name} couldn't take a replacement.",
                            :css_class => "player#{ply.seat}")
    else
      # Player has a choice of replacements; ask them
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{trashed_cost}",
                                 :text => "Take a replacement card with Upgrade",
                                 :player => ply,
                                 :game => game)
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
    if (params[:pile_index].to_i < 0 ||
        params[:pile_index].to_i > game.piles.length - 1)
      # Asked to take an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif (game.piles[params[:pile_index].to_i].cost != (params[:trashed_cost].to_i + 1))
      # Asked to take an invalid card (wrong cost)
      return "Invalid request - card #{game.piles[params[:pile_index].to_i].card_type} is the wrong cost"
    end

    # Process the take.
    game.histories.create!(:event => "#{ply.name} took " +
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with Upgrade.",
                          :css_class => "player#{ply.seat} card_gain")

    ply.gain(parent_act, game.piles[params[:pile_index].to_i].id)

    return "OK"
  end
end
