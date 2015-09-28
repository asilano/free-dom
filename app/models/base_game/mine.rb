class BaseGame::Mine < Card
  costs 5
  action
  card_text "Action (cost: 5) - Trash a Treasure card from your hand. " +
                       "Gain a Treasure card costing up to 3 more, and put " +
                       "it into your hand."

  def play(parent_act)
    super

    if player.cards(true).hand.select {|c| c.is_treasure?}.map(&:class).uniq.length == 1
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
                               pile.card_class.is_treasure? &&
                               !pile.cards.empty?)
                            end
                          }]
    end
  end

  resolves(:trash).validating_params_has(:card_index).
                   validating_param_is_card(:card_index, scope: :hand, &:is_treasure?).
                   with do
    # Trash the selected card, and create a new PendingAction for picking up
    # the Mined card.
    card = actor.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{actor.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{actor.seat} card_trash")

    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_take;trashed_cost=#{trashed_cost}",
                                     :text => "Take a replacement card with #{self}",
                                     :player => player,
                                     :game => game)

    "OK"
  end

  resolves(:take).validating_params_has(:pile_index).
                  validating_param_is_pile(:pile_index) { card_class.is_treasure? &&
                                                            cost <= my{params}[:trashed_cost].to_i + 3 }.
                  with do
    # Process the take.
    game.histories.create!(:event => "#{actor.name} took " +
           "#{game.piles[params[:pile_index].to_i].card_class.readable_name} with Mine.",
                          :css_class => "player#{actor.seat} card_gain")
    actor.gain(parent_act, :pile => game.piles[params[:pile_index].to_i], :location => "hand")

    "OK"
  end
end
