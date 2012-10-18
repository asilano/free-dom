class BaseGame::Mine < Card
  costs 5
  action
  card_text "Action (cost: 5) - Trash a Treasure card from your hand. " +
                       "Gain a Treasure card costing up to 3 more, and put " +
                       "it into your hand."

  def play(parent_act)
    super

    if player.cards.hand(true).select {|c| c.is_treasure?}.map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve_trash directly
      ix = player.cards.hand.index {|c| c.is_treasure?}
      return resolve_trash(player, {:card_index => ix}, parent_act)
    elsif !(player.cards.hand.any? {|c| c.is_treasure?})
      # Holding no treasure cards. Just log
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
                          :cards => player.cards.hand.map do |card|
                                      card.is_treasure?
                                    end
                         }]
    when "take"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Take",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "take",
                                        :trashed_cost => params[:trashed_cost]},
                            :piles => game.piles.map do |pile|
                              (pile.cost <= (params[:trashed_cost].to_i + 3) &&
                               pile.card_class.is_treasure?)
                            end
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
    elsif !ply.cards.hand[params[:card_index].to_i].is_treasure?
      # Asked to trash an invalid card (not a treasure)
      return "Invalid request - card index #{params[:card_index]} is not a treasure"
    end

    # All checks out. Carry on

    # Trash the selected card, and create a new PendingAction for picking up
    # the Mined card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{ply.seat} card_trash")

    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{trashed_cost}",
                                     :text => "Take a replacement card with #{self}",
                                     :player => player,
                                     :game => game)

    return "OK"
  end

  def resolve_take(ply, params, parent_act)
    # We expect to have been passed a :pile_index
    if not params.include? :pile_index
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    if ((params.include? :pile_index) and
           (params[:pile_index].to_i < 0 or
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to take an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif not game.piles[params[:pile_index].to_i].card_class.is_treasure?
      # Asked to take an invalid card (not a treasure)
      return "Invalid request - card #{game.piles[params[:pile_index].to_i].card_type} is not a treasure"
    elsif (params.include? :pile_index) and
          (not game.piles[params[:pile_index].to_i].cost <= (params[:trashed_cost].to_i + 3))
      # Asked to take an invalid card (too expensive)
      return "Invalid request - card #{game.piles[params[:pile_index].to_i].card_type} is too expensive"
    end

    # Process the take.
    game.histories.create!(:event => "#{ply.name} took " +
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with Mine.",
                          :css_class => "player#{ply.seat} card_gain")
    ply.gain(parent_act, game.piles[params[:pile_index].to_i].id, :location => "hand")

    return "OK"
  end
end
