class Hinterlands::Farmland < Card
  costs 6
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end}
  victory :points => 2
  card_text "Victory (cost: 6) - 2 points. / When you buy this, trash a card from your hand. Gain a card costing exactly 2 more than the trashed card."

  # Notice a buy event. If it's Farmland itself, queue up the trash/upgrade action
  def self.witness_buy(params)
    ply = params[:buyer]
    pile = params[:pile]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card bought is Farmland, and if so queue to do the upgrade
    if pile.card_class == self
      farmland = pile.cards.first
      if ply.cards.hand(true).map(&:class).uniq.length == 1
        # Only holding one type of card. Call resolve_trash directly
        farmland.resolve_trash(ply, {:card_index => 0}, parent_act)
      elsif ply.cards.hand.empty?
        # Holding no cards. Just log
        game.histories.create!(:event => "#{ply.name} trashed nothing buying #{farmland}.",
                              :css_class => "player#{ply.seat} card_trash")
      else
        # Create a PendingAction to trash a card
        act = parent_act.children.create!(:expected_action => "resolve_#{self}#{farmland.id}_trash",
                                         :text => "Trash a card with #{farmland}",
                                         :player => ply,
                                         :game => game)
      end
    end

    # Adding the extra gain does not affect the buy of Farmland itself in any way.
    return false
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
        (pile.cost == (params[:trashed_cost].to_i + 2)) && !pile.empty?
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

  # Copied from Upgrade
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

    # Trash the selected card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost

    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{ply.seat} card_trash")

    valid_piles = game.piles.select do |pile|
      (pile.cost == (trashed_cost + 2)) && !pile.empty?
    end

    if valid_piles.length == 1
      # Only one possibility for a replacement; take it automatically
      game.histories.create!(:event => "#{ply.name} took " +
           "#{valid_piles[0].card_class.readable_name} with Farmland.",
                          :css_class => "player#{ply.seat} card_gain")

      ply.gain(parent_act, valid_piles[0].id)
    elsif valid_piles.length == 0
      # No possible replacements
      game.histories.create!(:event => "#{ply.name} couldn't take a replacement.",
                            :css_class => "player#{ply.seat}")
    else
      # Player has a choice of replacements; ask them
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{trashed_cost}",
                                 :text => "Take a replacement card with #{self.class.readable_name}",
                                 :player => ply,
                                 :game => game)
    end

    return "OK"
  end

  # Still copied from Upgrade
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
    end
    pile = game.piles[params[:pile_index].to_i]
    if (pile.cost != (params[:trashed_cost].to_i + 2))
      # Asked to take an invalid card (wrong cost)
      return "Invalid request - card #{pile.card_type} does not cost #{params[:trashed_cost].to_i + 2}"
    end

    # Process the take.
    game.histories.create!(:event => "#{ply.name} took " +
           "#{pile.card_class.readable_name} with #{self.class.readable_name}.",
                          :css_class => "player#{ply.seat} card_gain")

    ply.gain(parent_act, pile.id)

    return "OK"
  end
end
