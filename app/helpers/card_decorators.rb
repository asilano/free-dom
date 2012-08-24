# This module is "extend"ed into Card. 
module CardDecorators
  
  ######
  # Basic decorators
  ######
  
  # Define the cost of a card, modified by Bridges
  def costs(cost)
    raise unless cost.is_a? Fixnum
    class_attribute :raw_cost
    self.raw_cost = cost
  end
  
  # Define a card as a Treasure with the specified value
  def treasure(opts)
    raise unless opts.include?(:cash) || opts[:special]
    def self.is_treasure? 
      true  
    end
    class_attribute :cash
    self.cash = opts[:cash]    
    
    if opts[:special]
      def self.is_special?
        true
      end
    end
  end
  
  # Define a card as a Victory with the specified points
  def victory(opts = {}, &block)
    raise unless block_given? or opts.include? :points
    def self.is_victory? 
      true 
    end
    if block_given?
      define_method(:points) do
        instance_eval &block
      end
    else      
      class_attribute :points 
      self.points = opts[:points]
    end
  end
  
  def reaction(opts = {})
    def self.is_reaction?
      true
    end
    class_attribute :react_trigger
    self.react_trigger = opts[:to] || :attack
  end
  
  # Define starting pile sizes; and instate before_save hook for :unlimited cards
  def pile_size(size = nil, &block)
    if size == :unlimited
      def self.starting_size(num_players) 
        :unlimited  
      end
      
      before_save do
        if location_changed? && location_was.present?
          if location_was == 'pile'
            # Moved out of pile. Duplicate
            self.class.create!(attributes.merge(changed_attributes).reject{|k| k == "id" || k == "type"})
          elsif location == 'pile'
            # Moved back to pile. Destroy
            destroy
          end
        end
      end      
    elsif block_given?
      @size_proc = block
      def self.starting_size(num_players)
        @size_proc.call(num_players)
      end          
    else
      raise
    end
  end
  
  # Define the card text
  def card_text(text)
    class_attribute :text
    self.text = text
  end
  
  def action(opts = Hash.new(nil))
    def self.is_action? 
      true 
    end

    # Durations
    if opts[:duration]
      def self.is_duration? 
        true 
      end
    end

    if opts[:attack]
      class_attribute :order_relevant, :affects_attacker
      self.order_relevant = opts[:order_relevant]
      self.affects_attacker = opts[:affects_attacker]
      include AttackMethods
    end          
  end

  
  module AttackMethods
    ######
    # Attacks
    ######
    # By decorating a Card-subclass with action :attack => true, 
    #                                           [:order_relevant => lambda{when_relevant},]
    #                                           [:affects_attacker => true]
    # the class will gain useful methods.
    #
    # Call attack(parent_act) from within play() to queue up the attack actions (and 
    # reactions).
    #
    # Call determine_react_controls(...) from within determine_controls to set up
    # controls for reacting players. resolve_react is defined for you.
    #
    # You still have to define attackeffect, and any choice actions, manually.
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def is_attack? 
        true 
      end
    end
    
    # Queue up a single action to be later exploded into everything needed for the attack
    def attack(parent_act, params = {})
      action = "resolve_#{self.class}#{id}_startattack"
      action += ";" + params.map {|k,v| "#{k}=#{v}"}.join(';') unless params.empty?
      parent_act.queue(:expected_action => action,      
                       :game => game)
                       
      return "OK"
    end
    
    # Set up the "Play" stuff relating to the attack, including PendingActions    
    def startattack(params)
      parent_act = params.delete :parent_act
      # Considering each player in turn, 
      # create a Game-scope pending action to suffer the attack. If the player
      # owns a reaction, hang an action off that one for the player to react.
      #
      # Whether the order of the attacks is relevant depends on :order_relevant
      param_string = ""
      if not params.empty?
        param_string = ";" + params.map{|k,v| "#{k}=#{v}"}.join(";")
      end  
      
      player.other_players.reverse.each do |ply|
        attack_act = parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}" + 
                                                                    "_doattack;" + 
                                                                    "target=#{ply.id};" +
                                                                    "source=#{player.id}" +
                                                                    param_string,
                                                :game => game)
        
        # Handle automoating here. If the attacked player has a Moat in hand
        # and Automoat enabled, call Moat.react. If they have no other reaction,
        # also suppress the "react" action.
        moat = ply.cards.hand.of_type("BaseGame::Moat")
        non_moat_reaction = ply.cards.hand.any? {|card| (card.is_reaction? && card.react_trigger == :attack && (card.class != BaseGame::Moat))}

        # Also lighthouses (which are always automatic, but the player can still play other reactions)
        lighthouse = ply.cards.enduring.of_type("Seaside::Lighthouse")
        
        if !lighthouse.empty?
          # Code copied from moat
          # Note - we can still auto from here, though we won't use a moat if
          # the lighthouse has already defended.
          game.histories.create(:event => "#{ply.name} has a lighthouse in play, negating the attack",
                                :css_class => "player#{ply.seat} play_reaction")
          if attack_act.expected_action !~ /moated=true/
            attack_act.expected_action += ";moated=true"
            attack_act.save!
          end
        else
          # Automoat if we can
          if ply.settings.automoat && !moat.empty?
            moat[0].react(attack_act, attack_act)
          end
        end
        
        if ( !ply.settings.automoat ) || non_moat_reaction
          # If we're NOT automoating, or there are non-moats to select
          # then go ahead and offer them to the player
          react_act = attack_act.children.create(:expected_action => "resolve_#{self.class}#{id}_react",
                                                 :text => "React to #{self.class.readable_name}")
          react_act.player = ply
          react_act.game = game
          react_act.save
        end
        
        if self.class.order_relevant && instance_exec(params, &self.class.order_relevant)
          # Players need to be attacked in order, so update parent_act
          parent_act = attack_act
        end
      end   
      
      if self.class.affects_attacker
        # Attack also affects the attacker. Create the attack action for the attacker themself (e.g, Spy)
        parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}" + 
                                                       "_doattack;" + 
                                                       "target=#{player.id};" +
                                                       "source=#{player.id}",
                                   :game => game)        
        
        # All existing Reactions (Moat, Secret Chamber) only work on /other/ player's attacks.
        # Hence this section is commented out.
        #if player.cards.hand.any? {|card| card.is_reaction?}
        #  react_act = attack_act.children.create(:expected_action => "resolve_#{self.class}#{id}_react",
        #                                         :text => "React to #{self.class}")
        #  react_act.player = player
        #  react_act.game = game
        #  react_act.save
        #end
      end
      
      return "OK"
    end

    
    # Set up controls for reactions, and handling for the reaction actions
    def determine_react_controls(player, controls, substep, params)
      if substep == "react"
        controls[:hand] += [{:type => :button,
                             :action => :resolve,
                             :name => "react",
                             :text => "React",
                             :nil_action => "Don\'t react",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "react"}.merge(params),
                             :cards => player.cards.hand.map do |card|
                               card.is_reaction?
                             end
                            }]
      end 
    end
      
    def resolve_react(ply, params, parent_act)
      # This is at the scope of the attackees - and is registering a Reaction
      # We expect to have been passed either :nil_action or a :card_index
      if (not params.include? :nil_action) and (not params.include? :card_index)
        return "Invalid parameters"
      end
      
      # Processing is pretty much the same as a Play; code shamelessly yoinked from
      # Player.play_action.
      if ((params.include? :card_index) and 
          (params[:card_index].to_i < 0 or
           params[:card_index].to_i > ply.cards.hand.length - 1))            
        # Asked to play an invalid card (out of range)        
        return "Invalid request - card index #{params[:card_index]} is out of range"
      elsif params.include? :card_index and not ply.cards.hand[params[:card_index].to_i].is_reaction?
        # Asked to play an invalid card (not an reaction)
        return "Invalid request - card index #{params[:card_index]} is not an reaction"
      end
      
      # Now process the reaction played
      if params[:nil_action]
        # Player has chosen to play no reaction. If we stop now, the Game will do
        # the right thing
        unless params.include? :nolog and params[:nolog] == "true"
          game.histories.create(:event => "#{ply.name} played no reaction.",
                                :css_class => "player#{ply.seat} no_react")
        end
        rc = "OK"
      else
        # Player played a reaction. Check that the parent action is a Game-level
        # action to make the attack effect happen, and add a child to ask for
        # further reactions. 
        if parent_act.expected_action !~ /^resolve_#{self.class}#{id}_doattack/
          return "Unexpected parent playing reaction"
        end
        react_act = parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}_react;nolog=true",
                                                 :text => "React to #{readable_name}",
                                                 :player => ply,
                                                 :game => game)
          
        # Pass the reaction action in to the reaction handler as parent action.                        
        rc = ply.cards.hand[params[:card_index].to_i].react(parent_act, react_act)

      end
      
      save!
      
      return rc
    end
      
    # Simple wrapper to call through to attackeffect, as modified by any
    # Reactions played.
    def doattack(params)
      if params.include? :moated and params[:moated] == "true"
        return "OK"
      else
        attackeffect(params)
      end
    end
  end
end
