# 1	Embargo	Seaside	Action	$2	+2 Coins, Trash this card. Put an Embargo token on top of a Supply pile. - When a player buys a card, he gains a Curse card per Embargo token on that pile.

class Seaside::Embargo < Card
  costs 2
  action
  card_text "Action (cost: 2) - +2 Cash. Trash this card. Put an Embargo token on top of a Supply pile. When a player buys a card, he gains a Curse card per Embargo token on that pile."
  
  def play(parent_act)
    super
    
    # Have to do everything before the trash, or player is nil.
    player.add_cash(2)
    
    # Create a pending action to pick a pile to Embargo
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_embargo",
                               :text => "Choose a pile to Embargo",
                               :player => player,
                               :game => game)
    
    # Now log and trash
    game.histories.create!(:event => "#{player.name} trashed #{readable_name}.",
                          :css_class => "player#{player.seat}")
    trash    
    

    
    return "OK"
  end
  
  def determine_controls(player, controls, substep, params)
    case substep
    when "embargo"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :name => "embargo",
                            :text => "Embargo",
                            :nil_action => nil,
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "embargo"},
                            :piles => [true] * game.piles.length
                          }]
    end
  end
  
  def resolve_embargo(ply, params, parent_act)
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
    end
    
    # Create Embargo state on that pile if it doesn't already have it
    pile = game.piles[params[:pile_index].to_i]
    pile.state_will_change!
    pile.state ||= {}
    pile.state[:embargo] ||= 0
    pile.state[:embargo] += 1
    pile.save!
    
    game.histories.create!(:event => "#{ply.name} added an Embargo counter to the #{pile.card_class.readable_name} pile.",
                          :css_class => "player#{ply.seat}")
    
    return "OK"
  end

  def self.handle_embargoed_buy(ply, pile, parent_act)
    # Pile from which the player bought was embargoed. Give the player that many Curses.    
    game = ply.game
    curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
    
    num_to_gain = [curses_pile.cards.count, pile.state[:embargo]].min
    game.histories.create!(:event => "#{ply.name} gained #{num_to_gain} Curse#{'s' if num_to_gain > 1} from Embargo.", 
                          :css_class => "player#{ply.seat} card_gain") unless num_to_gain == 0

    num_to_gain.times do |ix|
      ply.queue(parent_act, :gain, :pile => curses_pile.id)      
    end
    
    if num_to_gain < pile.state[:embargo]
      diff = pile.state[:embargo] - num_to_gain
      game.histories.create!(:event => "#{ply.name} should have gained #{diff} more Curse#{'s' if diff != 1} from Embargo, but the Curse pile was empty.", 
                            :css_class => "player#{ply.seat}")
    end
  end
  
end

