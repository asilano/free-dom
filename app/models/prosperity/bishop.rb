# Bishop (Action - $4) - +1 Cash, +1 VP. Trash a card from your hand. +VP equal to half its cost in coins, rounded down. Each other player may trash a card from his hand.

class Prosperity::Bishop < Card
  action
  costs 4
  card_text "Action (cost: 4) +1 Cash, +1 VP. Trash a card from your hand. +VP equal to half its cost in coins, rounded down. Each other player may trash a card from his hand."

  def play(parent_act)
    super

    # Grant the cash and fixed VP boost first
    player.add_cash(1)
    player.add_vps(1)

    game.histories.create!(:event => "#{player.name} gained 1 cash and 1 point from #{readable_name}.",
                          :css_class => "player#{player.seat} score")

    # Now set up the trash actions. They can all be simultaneous.
    if player.cards.hand(true).map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve_owner directly
      rc = resolve_owner(player, {:card_index => 0}, parent_act)
      return rc unless rc =~ /^OK/
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} trashed nothing, as their hand was empty.",
                            :css_class => "player#{player.seat} card_trash")
    else
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_owner",
                                 :text => "Trash a card for VPs with Bishop",
                                 :player => player,
                                 :game => game)
    end

    player.other_players.each do |ply|
      if !ply.cards.hand.empty?
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_other",
                                   :text => "Trash a card with #{player.name}'s Bishop",
                                   :player => ply,
                                   :game => game)
      end
    end

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    # Controls are nearly the same for the two "substeps" of "owner" and "other"
    controls[:hand] += [{:type => :button,
                        :action => :resolve,
                        :text => "Trash",
                        :nil_action => (substep == "other" ? "Trash nothing" : nil),
                        :params => {:card => "#{self.class}#{id}",
                                    :substep => substep},
                        :cards => [true] * player.cards.hand.size
                       }]
  end

  def resolve_owner(ply, params, parent_act)
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
    # Trash the selected card
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash

    # And grant points. The player is guaranteed to have a non-nil score by now, since they gained 1
    # when they played Bishop. We round down - taking advantage of the quirks of integer arithmetic
    player.add_vps(card.cost / 2)
    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand, gaining #{card.cost / 2} point#{card.cost / 2 == 1 ? '' : 's'}.",
                          :css_class => "player#{ply.seat} card_trash score")

    return "OK"
  end

  def resolve_other(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :card_index
    if (not params.include? :nil_action) and (not params.include? :card_index)
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
    if params.include? :nil_action
      # Player has chosen to "Trash nothing". Just record the fact.
      game.histories.create!(:event => "#{ply.name} trashed nothing with #{player.name}'s #{readable_name}.",
                            :css_class => "player#{ply.seat} card_trash")
    else
      # Trash the selected card
      card = ply.cards.hand[params[:card_index].to_i]
      card.trash
      game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand.",
                            :css_class => "player#{ply.seat} card_trash")
    end

    return "OK"
  end
end