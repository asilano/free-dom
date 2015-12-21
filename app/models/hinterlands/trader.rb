class Hinterlands::Trader < Card
  action
  reaction :to => :pre_gain
  costs 4
  card_text "Action (Reaction; cost: 4) - Trash a card from your hand. " +
            "Gain a number of Silvers equal to its cost in coins. / " +
            "When you would gain a card, you may reveal this from your hand. If you do, instead gain a Silver."

  #before_save :check_replacement_action

  def play(parent_act)
    super

    if player.cards.hand.empty?
      # No cards in hand. Just log.
      game.histories.create(:event => "#{player.name} trashed nothing.",
                            :css_class => "ply#{player.seat} card_trash")
    elsif player.cards.hand.map(&:class).uniq.length == 1
      # Only one type of card in hand. Call resolve_trash directly to trash it
      resolve_trash(player, {:card_index => 0}, parent_act)
    else
      # Queue up the request to trash a card
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                  :text => "Trash a card with #{self}",
                                  :game => game,
                                  :player => player)
    end

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "trash"
      controls[:hand] += [{:type => :button,
                           :text => "Trash",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "trash"},
                           :cards => [true] * player.cards.hand.size
                          }]
    when "react"
      # Reaction controls
      card_name = params[:card_type].constantize.readable_name
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :label => "Apply #{self} to #{card_name}?",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "react"}.merge(params),
                             :options => [{:text => "No - gain #{card_name}",
                                           :choice => "normal"},
                                          {:text => "Yes - gain Silver",
                                           :choice => "silver"}]
                            }]
    end
  end

  resolves(:trash).validating_params_has(:card_index).
                    validating_param_is_card(:card_index, scope: :hand).
                    with do
    # Trash the selected card, and log
    card = actor.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{actor.name} trashed a #{card} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{actor.seat} card_trash")

    # Now gain as many Silvers as the trashed card's cost
    silver_pile = game.piles.find_by_card_type('BasicCards::Silver')
    silvers_text = silver_pile.card_class.readable_name + (trashed_cost == 1 ? '' : 's')
    game.histories.create!(:event => "#{actor.name} gained #{trashed_cost} #{silvers_text} from #{self}.",
                           :css_class => "player#{actor.seat} card_gain")
    trashed_cost.times { actor.gain(parent_act, :pile => silver_pile) }

    "OK"
  end

  def self.witness_pre_gain_queue(params)
    card = params[:card] || params[:pile].cards.first
    parent_act = params[:parent_act]

    if card.class != BasicCards::Silver
      # Someone is about to gain something that isn't a Silver.
      # If they're holding Trader, ask them if they want a Silver instead.
      actor = params[:gainer]
      trader = actor.cards.hand.of_type(to_s).first
      if trader
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self}#{trader.id}_react;card_type=#{card.class}",
                                                 :text => "Choose whether to react with #{readable_name}",
                                                 :player => actor,
                                                 :game => trader.game)

        # Because of when this trigger occurs, other triggers can remove the Trader from hand before
        # the gain is to be modified. Therefore, store the action's ID on the Trader, so we can
        # remove the action if the Trader goes away.
        trader.state = parent_act.id
        trader.save!
      end
    end

    return parent_act
  end

  resolves(:react).validating_params_has(:choice).
                    validating_param_value_in(:choice, 'normal', 'silver').
                    with do
    # Check that the gain action which is this one's parent is for the expected card-type
    card_id = parent_act.expected_action.match(/card_id=(\d+)/).to_a[1]
    pile_id = parent_act.expected_action.match(/pile_id=(\d+)/).to_a[1]
    card_type = (card_id && Card.find(card_id).class) ||
                (pile_id && Pile.find(pile_id).card_type)

    if (card_type.to_s != params[:card_type])
      raise "Mismatch: expecting to gain 'params[:card_type] but action is for #{card_type}"
    end

    # All checks out. Do what the user asked
    if params[:choice] == 'normal'
      # No-op. Don't even log
    else
      # Log
      game.histories.create!(:event => "#{actor.name} reacted with #{self} to gain a Silver instead.",
                             :css_class => "player#{actor.seat}")

      # Remove the parent action, and create a new one to gain a Silver instead
      new_parent = parent_act.parent
      parent_act.remove!
      silver_pile = game.piles.find_by_card_type("BasicCards::Silver")
      actor.gain(new_parent, :pile => silver_pile)
    end

    # Stop this card referencing its replacement action
    self.state = nil
    save!

    "OK"
  end

  # No-op action for when a Trader disappears after triggering, such as with Farmland
  def nothing(_)
  end

private

  # If Trader is being moved out of the hand, either move its replacement action onto
  # another Trader which is still in hand, or negate it. This covers cases like Farmland
  # trashing the Trader before it's bought
  def check_replacement_action
    if location_changed? && location_was == 'hand'
      if state
        repl_action = PendingAction.find(state)

        other_trader = Player.find(player_id_was).cards.hand.of_type(self.class.to_s).where(['id != ?', self]).first

        if other_trader
          repl_action.expected_action.sub!(self.id.to_s, other_trader.id.to_s)
          other_trader.state = repl_action.id
          other_trader.save!
        else
          # We can't just destroy the action, since other code may be holding references
          # to it. Instead, mutate it into a no-op.
          repl_action.expected_action = "resolve_#{self.class}#{id}_nothing"
          repl_action.player = nil
          repl_action.save!
        end

        self.state = nil
        save
      end
    end

    true
  end
end