# TradeRoute (Action - $3) - +1 Buy. +1 Cash per token on the Trade Route mat. Trash a card from your hand. / Setup: Put a token on each Victory card Supply pile. When a card is gained from that pile, move the token to the Trade Route mat.

class Prosperity::TradeRoute < Card
  action
  costs 3
  card_text "Action (cost: 3) - +1 Buy. +1 Cash per token on the Trade Route mat. Trash a card from your hand. / Setup: Put a token on each Victory card Supply pile. When a card is gained from that pile, move the token to the Trade Route mat."

  # Setup is handled by Game; token moving by Card#gain

  def play(parent_act)
    super

    player.add_buys(1, parent_act)
    player.cash += game.facts[:trade_route_value]
    player.save!

    if player.cards(true).hand.map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve_trash directly
      return resolve_trash(player, {:card_index => 0}, parent_act)
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} trashed nothing, as their hand was empty.",
                            :css_class => "player#{player.seat} card_trash")
    else
      parent_act.queue(:expected_action => "resolve_#{self.class}#{id}_trash",
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

    # Trash the selected card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash

    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand.",
                          :css_class => "player#{ply.seat} card_trash")

    return "OK"
  end

end