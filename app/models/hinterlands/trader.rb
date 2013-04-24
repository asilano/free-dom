class Hinterlands::Trader < Card
  action
  reaction :to => :pre_gain
  costs 4
  card_text "Action (Reaction; cost: 4) - Trash a card from your hand. " +
            "Gain a number of Silvers equal to its cost in coins / " +
            "When you would gain a card, you may reveal this from your hand. If you do, instead gain a Silver."

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

    # Trash the selected card, and log
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{ply.name} trashed a #{card} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{ply.seat} card_trash")

    # Now gain as many Silvers as the trashed card's cost
    silver_pile = game.piles.find_by_card_type('BasicCards::Silver')
    trashed_cost.times {ply.gain(parent_act, :pile => silver_pile)}

    return "OK"
  end

  def self.witness_pre_gain_queue(params)
    card = params[:card] || params[:pile].cards.first

    if card.class != BasicCards::Silver
      # Someone is about to gain something that isn't a Silver.
      # If they're holding Trader, ask them if they want a Silver instead.
      ply = params[:gainer]
      parent_act = params[:parent_act]
      trader = ply.cards.hand.of_type(to_s).first
      if trader
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self}#{trader.id}_react;card_type=#{card.class}",
                                                 :text => "Choose whether to react with #{readable_name}",
                                                 :player => ply,
                                                 :game => trader.game)
      end
    end

    return parent_act
  end

  def resolve_react(ply, params, parent_act)
    # We expect to have a :choice parameter, either "normal" or "silver"
    if !params.include?(:choice) ||
        !params[:choice].in?(["normal", "silver"])
      return "Invalid parameters"
    end

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
      game.histories.create!(:event => "#{ply.name} reacted with #{self} to gain a Silver instead.",
                             :css_class => "player#{ply.seat}")

      # Remove the parent action, and create a new one to gain a Silver instead
      new_parent = parent_act.parent
      parent_act.remove!
      silver_pile = game.piles.find_by_card_type("BasicCards::Silver")
      ply.gain(new_parent, :pile => silver_pile)
    end

    "OK"
  end
end