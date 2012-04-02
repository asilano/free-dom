# 16	Salvager	Seaside	Action	$4	+1 Buy, Trash a card from your hand. +Cash equal to its cost.

class Seaside::Salvager < Card
  costs 4
  action
  card_text "Action (cost: 4) - +1 Buy. Trash a card from your hand. +Cash equal to its cost."
  
  def play(parent_act)
    super

    # +1 buy
    player.add_buys(1, parent_act)

    if player.cards.hand(true).map(&:class).uniq.length == 1
      # Only holding one type of card. Call resolve_trash directly
      return resolve_trash(player, {:card_index => 0}, parent_act)
    elsif player.cards.hand.empty?
      # Holding no cards. Just log
      game.histories.create!(:event => "#{player.name} trashed nothing, as their hand was empty.",
                            :css_class => "player#{player.seat}")
      save!
    else
      # Choose a card to trash
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_trash",
                                       :text => "Trash a card with Salvager",
                                       :player => player,
                                       :game => game)
    end

    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
      controls[:hand] += [{:type => :button,
                          :action => :resolve,
                          :name => "trash",
                          :text => "Trash",
                          :nil_action => nil,
                          :params => {:card => "#{self.class}#{id}",
                                      :substep => "trash"},
                          :cards => [true] * player.cards.hand.size
                         }]
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
    
    # Trash the selected card
    card = ply.cards.hand[params[:card_index].to_i]
    card.trash
    trashed_cost = card.cost
    game.histories.create!(:event => "#{ply.name} trashed a #{card.class.readable_name} from hand (cost: #{trashed_cost}).",
                          :css_class => "player#{ply.seat} card_trash")

    # And gain the coin for it
    player.cash += trashed_cost
    player.save!
    
    return "OK"
  end


end

