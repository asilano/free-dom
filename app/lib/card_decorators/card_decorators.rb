# # This module is "extend"ed into Card.
module CardDecorators
  module CardDecorators
    # ######
    # # Basic decorators
    # ######

    # Define the text of a card
    def text(*lines)
      str = lines
        .slice_when { |l| l == :hr }
        .map { |sub| sub.reject { |l| l == :hr}.join("\n") }
        .join("<hr>")
      define_method(:text) { str }
      define_singleton_method(:card_text) { str }
    end

    # Define the raw cost of a card, before any modifications like Bridge
    def costs(cost)
      raise unless cost.is_a? Integer

      define_singleton_method(:raw_cost) { cost }
    end

    def treasure?; false; end
    def special?; false; end
    # Define a card as a Treasure with the specified value
    def treasure(opts)
      raise ArgumentError, 'Treasure must specify cash or special' unless opts.key?(:cash) || opts[:special]

      define_singleton_method(:treasure?) { true }
      define_method(:cash) { opts[:cash] } if opts.key? :cash

      return unless opts[:special]

      define_singleton_method(:special?) { true }
    end

    # Define a card as a Victory with the specified points. Default its
    # pile size.
    def victory?; false; end
    def victory(opts = {}, &block)
      raise ArgumentError, 'Victory must define points' unless block_given? || opts.key?(:points)

      define_singleton_method(:victory?) { true }
      if block_given?
        define_method(:points) do
          instance_eval(&block)
        end
      else
        define_method(:points) { opts[:points] }
      end

      return if @pile_size_given

      pile_size do |num_players|
        case num_players
        when 2
          8
        when 3..Float::INFINITY
          12
        end
      end
      @pile_size_given = false
    end

    def curse?; false; end
    def curse
      define_singleton_method(:curse?) { true }
      define_method(:points) { -1 }
    end

    def action?; false; end
    def action
      define_singleton_method(:action?) { true }
    end

    def reaction?; false; end
    def reaction(from:, to:)
      define_singleton_method(:reaction?) { true }
      define_method(:reacts_from) { from }
      define_method(:reacts_to) { to }
    end

    def attack?; false; end
    def attack
      define_singleton_method(:attack?) { true }
      include AttackDecorators
    end

    def duration?; false; end
    def duration
      define_singleton_method(:duration?) { true }
    end

    # Define starting pile sizes
    def pile_size(size = nil, &block)
      if block_given?
        define_singleton_method(:starting_size, &block)
      else
        define_singleton_method(:starting_size) { |_| size }
      end
      @pile_size_given = true
    end

    # Pre-game setup, as on Trade Route or Border Guard
    def setup(&block)
      setup_procs << block
    end
    def setup_procs
      @setup_procs ||= []
    end
    def do_setup(game_state)
      setup_procs.each { |p| p.call(game_state) }
    end

    def on_gain(&block)
      on_trigger(GameEngine::Triggers::CardGained, &block)
    end

    def on_trash(&block)
      on_trigger(GameEngine::Triggers::CardTrashed, &block)
    end

    def on_trigger(trigger_class, &block)
      setup do |_game_state|
        filter = lambda do |card, *|
          card.is_a?(self)
        end

        trigger_class.watch_for(filter:   filter,
                                whenever: true,
                                &block)
      end
    end

  #   def action(opts = Hash.new(nil))
  #     def self.is_action?
  #       true
  #     end

  #     # Durations
  #     if opts[:duration]
  #       def self.is_duration?
  #         true
  #       end
  #     end

  #     if opts[:attack]
  #       class_attribute :order_relevant, :affects_attacker
  #       self.order_relevant = opts[:order_relevant]
  #       self.affects_attacker = opts[:affects_attacker]
  #       include AttackMethods
  #     end
  #   end

  #   def trigger(meth, opts)
  #     raise "No condition provided" unless opts.include?(:on)
  #     unless opts[:on].is_a?(Hash)
  #       raise "Options not a hash"
  #     end
  #     opts[:on].each {|key, val| raise "#{key.inspect} not a field" unless self.new.respond_to?("#{key}_was")}

  #     condition = lambda do |object|
  #       opts[:on].all? do |field, change|
  #         changed = method("#{field}_changed?").call
  #         if (change[0] != :any)
  #           changed &&= method("#{field}_was").call == change[0]
  #         end
  #         if (change[1] != :any)
  #           changed &&= method(field).call == change[1]
  #         end
  #         changed
  #       end
  #     end

  #     before_update meth, :if => condition
  #   end

  #   module AttackMethods
  #     ######
  #     # Attacks
  #     ######
  #     # By decorating a Card-subclass with action :attack => true,
  #     #                                           [:order_relevant => lambda{when_relevant},]
  #     #                                           [:affects_attacker => true]
  #     # the class will gain useful methods.
  #     #
  #     # Call attack(parent_act) from within play() to queue up the attack actions (and
  #     # reactions).
  #     #
  #     # Call determine_react_controls(...) from within determine_controls to set up
  #     # controls for reacting players. resolve_react is defined for you.
  #     #
  #     # You still have to define attackeffect, and any choice actions, manually.
  #     def self.included(base)
  #       base.extend(ClassMethods)
  #     end

  #     module ClassMethods
  #       def is_attack?
  #         true
  #       end
  #     end

  #     # Queue up a single action to be later exploded into everything needed for the attack
  #     def attack(parent_act, params = {})
  #       action = "resolve_#{self.class}#{id}_startattack"
  #       action += ";" + params.map {|k,v| "#{k}=#{v}"}.join(';') unless params.empty?
  #       parent_act.queue(:expected_action => action,
  #                        :game => game)

  #       return "OK"
  #     end

  #     # Set up the "Play" stuff relating to the attack, including PendingActions
  #     def startattack(params)
  #       # Find the parent action, and the attacker
  #       parent_act = params.delete :parent_act
  #       pre_attack = params.delete :pre_attack
  #       pre_attack_ply = params.delete :pre_attack_ply
  #       pre_attack_text = params.delete :pre_attack_text
  #       prevent_react = !!params[:prevent_react]
  #       params.delete :this_act_id

  #       # Considering each player in turn,
  #       # create a Game-scope pending action to suffer the attack. If the player
  #       # owns a reaction, hang an action off that one for the player to react.
  #       #
  #       # Whether the order of the attacks is relevant depends on :order_relevant
  #       param_string = ""
  #       if not params.empty?
  #         param_string = ";" + params.except(:attacker_id, :prevent_react).map{|k,v| "#{k}=#{v}"}.join(";")
  #       end

  #       if pre_attack
  #         # This attack has a step between reactions and the attack taking effect (such as
  #         # Minion and Pirate Ship's mode choice).
  #         # Create a single action which will later explode into actions for each player.
  #         action = "resolve_#{self.class}#{id}" + "_doattacks"
  #         action += ";" + params.map {|k,v| "#{k}=#{v}"}.join(';') unless params.empty?
  #         group_attack_act = parent_act.children.create(expected_action: action,
  #                                                       game: game)

  #         # And add the pre-attack action to happen before it.
  #         pre_attack_act = group_attack_act.children.create(expected_action: "resolve_#{self.class}#{id}_" +
  #                                                                             pre_attack,
  #                                                           text: pre_attack_text,
  #                                                           player: (pre_attack_ply ? Player.find(pre_attack_ply) : nil),
  #                                                           game: game)

  #         # Then add reaction actions for each other player
  #         add_attack_acts(params, param_string, pre_attack_act, group_attack_act, {}, :reactions)
  #       else
  #         # No pre-attack step, so add actions for the attack effect and reactions here
  #         # (unless the attack prevents reactions)
  #         if prevent_react
  #           add_attack_acts(params, param_string, parent_act, nil, {}, :attacks)
  #         else
  #           add_attack_acts(params, param_string, parent_act, nil, {}, :attacks, :reactions)
  #         end
  #       end

  #       return "OK"
  #     end

  #     # This is the action resolution of the placeholder created for an attack with a pre-attack action
  #     # We need to explode it here into actions for each individual attackee, taking account of any state
  #     # stored on it.
  #     def doattacks(params)
  #       parent_act = params.delete :parent_act
  #       state = params.delete :state
  #       params.delete :this_act_id
  #       param_string = ""
  #       if not params.empty?
  #         param_string = ";" + params.except(:attacker_id, :prevent_react).map{|k,v| "#{k}=#{v}"}.join(";")
  #       end

  #       add_attack_acts(params, param_string, parent_act, nil, state, :attacks)
  #     end

  #     def add_attack_acts(params, param_string, parent_act, attack_act, attack_state, *steps_to_add)
  #       add_attack = steps_to_add.include? :attacks
  #       add_react = steps_to_add.include? :reactions

  #       attacker = Player.where(:id => params.delete(:attacker_id)).first || player
  #       prevent_react = !!params.delete(:prevent_react)

  #       attacker.other_players.reverse.each do |ply|
  #         local_parent = parent_act

  #         if add_attack
  #           local_param_string = param_string.dup

  #           if (attack_state.andand.include? ply.id)
  #             local_param_string = [local_param_string, *attack_state[ply.id].map {|k,v| "#{k}=#{v}"}].join(';')
  #           end

  #           local_parent = parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}" +
  #                                                                         "_doattack;" +
  #                                                                         "target=#{ply.id};" +
  #                                                                         "source=#{attacker.id}" +
  #                                                                         local_param_string,
  #                                                     :game => game)
  #         end

  #         react_to = attack_act || local_parent

  #         if add_react && !prevent_react
  #           # Handle automoating here. If the attacked player has a Moat in hand
  #           # and Automoat enabled, call Moat.react. If they have no other reaction,
  #           # also suppress the "react" action.
  #           moat = ply.cards.hand.of_type("BaseGame::Moat")
  #           non_moat_reaction = ply.cards.hand.any? {|card| (card.is_reaction? &&
  #                                                             card.react_trigger == :attack &&
  #                                                             (card.class != BaseGame::Moat))}

  #           # Also lighthouses (which are always automatic, but the player can still play other reactions)
  #           lighthouse = ply.cards.enduring.of_type("Seaside::Lighthouse")

  #           if !lighthouse.empty?
  #             # Code copied from moat
  #             # Note - we can still auto from here, though we won't use a moat if
  #             # the lighthouse has already defended.
  #             game.histories.create(:event => "#{ply.name} has a lighthouse in play, negating the attack",
  #                                   :css_class => "player#{ply.seat} play_reaction")
  #             moat_attack(react_to, ply)
  #           else
  #             # Automoat if we can
  #             if ply.settings.automoat && !moat.empty?
  #               moat[0].react(react_to, local_parent)
  #             end
  #           end

  #           if ( !ply.settings.automoat ) || non_moat_reaction
  #             # If we're NOT automoating, or there are non-moats to select
  #             # then go ahead and offer them to the player
  #             react_act = local_parent.children.create(:expected_action => "resolve_#{self.class}#{id}_react",
  #                                                      :text => "React to #{self.class.readable_name}",
  #                                                      :player => ply,
  #                                                      :game => game)
  #           end
  #         end

  #         if self.class.order_relevant && instance_exec(params, &self.class.order_relevant)
  #           # Players need to be attacked in order, so update parent_act
  #           parent_act = local_parent
  #         end
  #       end

  #       if add_attack && self.class.affects_attacker
  #         # Attack also affects the attacker. Create the attack action for the attacker themself (e.g, Spy)
  #         parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}" +
  #                                                        "_doattack;" +
  #                                                        "target=#{attacker.id};" +
  #                                                        "source=#{attacker.id}",
  #                                    :game => game)

  #         # All existing Reactions (Moat, Secret Chamber) only work on /other/ player's attacks.
  #         # Hence this section is commented out.
  #         #if player.cards.hand.any? {|card| card.is_reaction?}
  #         #  react_act = attack_act.children.create(:expected_action => "resolve_#{self.class}#{id}_react",
  #         #                                         :text => "React to #{self.class}")
  #         #  react_act.player = player
  #         #  react_act.game = game
  #         #  react_act.save
  #         #end
  #       end

  #       return "OK"
  #     end

  #     # Set up controls for reactions, and handling for the reaction actions
  #     def determine_react_controls(player, controls, substep, params)
  #       if substep == "react"
  #         controls[:hand] += [{:type => :button,
  #                              :action => :resolve,
  #                              :text => "React",
  #                              :nil_action => "Don\'t react",
  #                              :params => {:card => "#{self.class}#{id}",
  #                                          :substep => "react"}.merge(params),
  #                              :cards => player.cards.hand.map do |card|
  #                                card.is_reaction?
  #                              end
  #                             }]
  #       end
  #     end

  #     def resolve_react(ply, params, parent_act)
  #       # This is at the scope of the attackees - and is registering a Reaction
  #       # We expect to have been passed either :nil_action or a :card_index
  #       if (not params.include? :nil_action) and (not params.include? :card_index)
  #         return "Invalid parameters"
  #       end

  #       # Processing is pretty much the same as a Play; code shamelessly yoinked from
  #       # Player.play_action.
  #       if ((params.include? :card_index) and
  #           (params[:card_index].to_i < 0 or
  #            params[:card_index].to_i > ply.cards.hand.length - 1))
  #         # Asked to play an invalid card (out of range)
  #         return "Invalid request - card index #{params[:card_index]} is out of range"
  #       elsif params.include? :card_index and not ply.cards.hand[params[:card_index].to_i].is_reaction?
  #         # Asked to play an invalid card (not an reaction)
  #         return "Invalid request - card index #{params[:card_index]} is not an reaction"
  #       end

  #       # Now process the reaction played
  #       if params[:nil_action]
  #         # Player has chosen to play no reaction. If we stop now, the Game will do
  #         # the right thing
  #         unless params.include? :nolog and params[:nolog] == "true"
  #           game.histories.create(:event => "#{ply.name} played no reaction.",
  #                                 :css_class => "player#{ply.seat} no_react")
  #         end
  #         rc = "OK"
  #       else
  #         # Player played a reaction. Check that the parent action is a Game-level
  #         # action to make the attack effect happen, and add a child to ask for
  #         # further reactions.
  #         attack_act = parent_act
  #         if (attack_act.expected_action !~ /_doattack/)
  #           attack_act = attack_act.parent until attack_act.expected_action =~ /_doattacks/
  #         end

  #         react_act = parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}_react;nolog=true",
  #                                                  :text => "React to #{readable_name}",
  #                                                  :player => ply,
  #                                                  :game => game)

  #         # Pass the reaction action in to the reaction handler as parent action.
  #         rc = ply.cards.hand[params[:card_index].to_i].react(attack_act, react_act)

  #       end

  #       save!

  #       return rc
  #     end

  #     # Simple wrapper to call through to attackeffect, as modified by any
  #     # Reactions played.
  #     def doattack(params)
  #       if params.include? :moated and params[:moated] == "true"
  #         return "OK"
  #       else
  #         attackeffect(params)
  #       end
  #     end
  #   end
  end
end
