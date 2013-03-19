class Intrigue::TradingPost < Card
  costs 5
  action
  card_text "Action (cost: 5) - Trash 2 cards from your hand. If you do, " +
            "gain a Silver card to your hand."

  def play(parent_act)
    super

    # Set up the right number of pending actions (2 if possible, no more than
    # cards in hand)
    if player.cards.hand(true).length == 0
      # No cards in hand. Just write a history.
      game.histories.create!(:event => "#{player.name} had no cards in hand to trash.",
                            :css_class => "player#{player.seat} card_trash")
    elsif player.cards.hand.length == 1
      # Exactly one card in hand - it must be trashed, but no Silver will be gained.
      game.histories.create!(:event => "#{player.name} must trash their only card, and will not gain a Silver.",
                            :css_class => "player#{player.seat} card_trash")
      return resolve_trash(player, {:card_index => 0, :gain => 'false'}, parent_act)
    elsif player.cards.hand.length == 2 || player.cards.hand.map(&:type).uniq.length == 1
      # Exactly two cards in hand, or only one type of card in hand - they must be trashed, and Silver will be gained
      rc = resolve_trash(player, {:card_index => 1, :gain => 'false'}, parent_act)
      return rc unless rc =~ /^OK/
      return resolve_trash(player, {:card_index => 0, :gain => 'true'}, parent_act)
    else
      # More than two cards in hand. Create actions to trash 2, and then gain a Silver
      parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash;gain=true",
                                              :text => "Trash one card with Trading Post",
                                              :player => player,
                                              :game => game)
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash;gain=false",
                                 :text => "Trash two cards with Trading Post",
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
                                      :substep => "trash",
                                      :gain => params[:gain]},
                          :cards => [true] * player.cards.hand.size
                         }]
    end
  end

  def resolve_trash(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if (not params.include? :card_index) or (not params.include? :gain)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) and
        (params[:card_index].to_i < 0 or
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to trash an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Carry on
    # Trash the selected card
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand.",
                          :css_class => "player#{ply.seat} card_trash")

    if params[:gain] == 'true'
      # Parameters indicate we should now grant a Silver to hand.
      silver_pile = game.piles.find_by_card_type("BasicCards::Silver")
      ply.gain(parent_act, :pile => silver_pile, :location => "hand")
      game.histories.create!(:event => "#{ply.name} gained a Silver to Hand.",
                            :css_class => "player#{ply.seat} card_gain")
    end

    return "OK"
  end
end