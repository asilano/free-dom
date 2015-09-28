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
      if ply.cards(true).hand.map(&:class).uniq.length == 1
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

  resolves(:trash).validating_params_has(:card_index).
                    validating_param_is_card(:card_index, scope: :hand).
                    with do
    # Trash the selected card.
    card = actor.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost

    game.histories.create!(:event => "#{actor.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{actor.seat} card_trash")

    valid_piles = game.piles.select do |pile|
      (pile.cost == (trashed_cost + 2)) && !pile.empty?
    end

    if valid_piles.length == 1
      # Only one possibility for a replacement; take it automatically
      game.histories.create!(:event => "#{actor.name} took " +
           "#{valid_piles[0].card_class.readable_name} with Farmland.",
                          :css_class => "player#{actor.seat} card_gain")

      actor.gain(parent_act, :pile => valid_piles[0])
    elsif valid_piles.length == 0
      # No possible replacements
      game.histories.create!(:event => "#{actor.name} couldn't take a replacement.",
                            :css_class => "player#{actor.seat}")
    else
      # Player has a choice of replacements; ask them
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{trashed_cost}",
                                 :text => "Take a replacement card with #{self.class.readable_name}",
                                 :player => actor,
                                 :game => game)
    end

    "OK"
  end

  resolves(:take).validating_params_has(:pile_index).
                  validating_params_has(:trashed_cost).
                  validating_param_is_pile(:pile_index) { cost == my{params}[:trashed_cost].to_i + 2}.
                  with do
    # Process the take.
    pile = game.piles[params[:pile_index].to_i]
    game.histories.create!(:event => "#{actor.name} took " +
           "#{pile.card_class.readable_name} with #{self.class.readable_name}.",
                          :css_class => "player#{actor.seat} card_gain")

    actor.gain(parent_act, :pile => pile)

    "OK"
  end
end
