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
  end

  # Define starting pile sizes
  def pile_size(size = nil, &block)
    if size
      define_singleton_method(:starting_size) do |n_ply|
        size
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

  def trigger(meth, opts)
    raise "No trigger provided" unless opts.include?(:on)
    #raise "Trigger isn't a trigger type" unless game.triggers[opts[:on]].kind_of? Triggers::Trigger
    raise "No condition provided" unless opts.include?(:when)
    raise "Condition not a Hash" unless opts[:when].is_a? Hash

    # Alias the setter for the attribute mentioned in the :when option, to
    # watch for the condition.
    opts[:when].each do |attr, val|
      define_method("#{attr}_with_check_#{val}=") do |new_val|
        if new_val == val
          game.triggers[opts[:on]].observe(self, meth)
        else
          game.triggers[opts[:on]].ignore(self, meth)
        end
        send("#{attr}_without_check_#{val}=", new_val)
      end
      alias_method_chain "#{attr}=", "check_#{val}"
    end

    # Called by a reaction card to tell the player it's available to react to an event
    define_method(:register_reaction) do |event, state|
      game.main_strand.log
      if state[:trigger_card].react_questions[event].nil?
        q = state[:trigger_card].react_questions[event] = game.ask_question(object: state[:trigger_card],
                                                                            actor: self.player,
                                                                            journal: state[:trigger_card].class::Journals::ReactJournal,
                                                                            expect: { state: state.to_yaml })
        q[:question].trigger_card = state[:trigger_card]
      end

      @can_react_to << event
      state[:trigger_card].react_questions[event]
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
      base::Journals.include(Journals)
    end

    module ClassMethods
      def is_attack?
        true
      end
    end

    module Journals
      class ConductAttackJournal < Journal
        causes :attackeffect
        validates_hash_keys :parameters do
          validates :victim_id, presence: true, player: true
        end
        text { "Conducting attack on #{game.players.where(id: parameters[:victim_id]).first.name}" }
        question(attribs: :victim_id)
      end

      class ReactJournal < Journal
        causes :doreact
        validates_hash_keys :parameters do
          validates :nil_action, presence: { if: ->(p) { p[:card_id].blank? } }
          validates :nil_action, absence: { unless: ->(p) { p[:card_id].blank? } }
          validates :card_id, card: { owner: :actor, satisfies: :is_reaction?, allow_nil: true }
        end
        before_save :make_hidden

        text do
          if card
            "#{player.name} reacted with #{card.readable_name}."
          else
            "#{player.name} chose not to react to #{self.readable_name}"
          end
        end

        question(attribs: [:state, :trigger_card], text: -> { "React to #{@trigger_card.readable_name}" }) do |q|
          {
            hand: {
              type: :button,
              text:  "React",
              nil_action: { text: "Don't react" },
              parameters: cards.hand.map { |c| c.id if c.can_react_to?(:attack) },
              expect: { state: q.state }
            }
          }
        end

        def make_hidden
          self.hidden = true if parameters[:nil_action]
        end
      end
    end

    def attack
      # Attack each (other) player in turn. Ignore reactions - they'll get triggered.
      parent_strand = game.current_strand
      player.other_players.each do |victim|
        # if victim.cards.enduring.of_type('Seaside::Lighthouse').present?
        #   # Victim has a Lighthouse in play
        #   game.add_history(:event => "Placeholder: #{victim.name} has a Lighthouse in play, negating the attack.",
        #                     :css_class => "player#{victim.seat} play_reaction")
        # elsif victim.settings.automoat && victim.cards.hand.of_type('BaseGame::Moat').present?
        #   # Victim is holding a Moat and has Automoat on
        #   game.add_history(event: "Placeholder: #{victim.name} reacted with a Moat, negating the attack.",
        #                     :css_class => "player#{victim.seat} play_reaction")
        # else
        #   attackeffect(target: victim)
        # end

        # Create a new strand for this attack, so the parent strand gets blocked
        game.current_strand = game.add_strand(parent_strand)

        # In order that attacking gets held up by any triggers, ask and answer a question here that will
        # kick off the attack.
        q = game.ask_question(object: self,
                              actor: nil,
                              journal: Journals::ConductAttackJournal,
                              expect: { victim_id: victim.id })

        j = game.find_journal(q[:template])
        unless j
          j = game.add_journal(type: Journals::ConductAttackJournal.to_s,
                               parameters: { victim_id: victim.id },
                               allow_defer: true)
        end

        # Trigger any effects that are watching for attack
        game.triggers[:attack].trigger(victim: victim, attacker: player, trigger_card: self, att_q: q, att_j: j)
      end
    end

    # Queue up a single action to be later exploded into everything needed for the attack
    def old_attack(parent_act, params = {})
      action = "resolve_#{self.class}#{id}_startattack"
      action += ";" + params.map {|k,v| "#{k}=#{v}"}.join(';') unless params.empty?
      parent_act.queue(:expected_action => action,
                       :game => game)

      return "OK"
    end

    # Set up the "Play" stuff relating to the attack, including PendingActions
    def old_startattack(params)
      # Find the parent action, and the attacker
      parent_act = params.delete :parent_act
      pre_attack = params.delete :pre_attack
      pre_attack_ply = params.delete :pre_attack_ply
      pre_attack_text = params.delete :pre_attack_text
      prevent_react = !!params[:prevent_react]
      params.delete :this_act_id

      # Considering each player in turn,
      # create a Game-scope pending action to suffer the attack. If the player
      # owns a reaction, hang an action off that one for the player to react.
      #
      # Whether the order of the attacks is relevant depends on :order_relevant
      param_string = ""
      if not params.empty?
        param_string = ";" + params.except(:attacker_id, :prevent_react).map{|k,v| "#{k}=#{v}"}.join(";")
      end

      if pre_attack
        # This attack has a step between reactions and the attack taking effect (such as
        # Minion and Pirate Ship's mode choice).
        # Create a single action which will later explode into actions for each player.
        action = "resolve_#{self.class}#{id}" + "_doattacks"
        action += ";" + params.map {|k,v| "#{k}=#{v}"}.join(';') unless params.empty?
        group_attack_act = parent_act.children.create(expected_action: action,
                                                      game: game)

        # And add the pre-attack action to happen before it.
        pre_attack_act = group_attack_act.children.create(expected_action: "resolve_#{self.class}#{id}_" +
                                                                            pre_attack,
                                                          text: pre_attack_text,
                                                          player: (pre_attack_ply ? Player.find(pre_attack_ply) : nil),
                                                          game: game)

        # Then add reaction actions for each other player
        add_attack_acts(params, param_string, pre_attack_act, group_attack_act, {}, :reactions)
      else
        # No pre-attack step, so add actions for the attack effect and reactions here
        # (unless the attack prevents reactions)
        if prevent_react
          add_attack_acts(params, param_string, parent_act, nil, {}, :attacks)
        else
          add_attack_acts(params, param_string, parent_act, nil, {}, :attacks, :reactions)
        end
      end

      return "OK"
    end

    # This is the action resolution of the placeholder created for an attack with a pre-attack action
    # We need to explode it here into actions for each individual attackee, taking account of any state
    # stored on it.
    def old_doattacks(params)
      parent_act = params.delete :parent_act
      state = params.delete :state
      params.delete :this_act_id
      param_string = ""
      if not params.empty?
        param_string = ";" + params.except(:attacker_id, :prevent_react).map{|k,v| "#{k}=#{v}"}.join(";")
      end

      add_attack_acts(params, param_string, parent_act, nil, state, :attacks)
    end

    def old_add_attack_acts(params, param_string, parent_act, attack_act, attack_state, *steps_to_add)
      add_attack = steps_to_add.include? :attacks
      add_react = steps_to_add.include? :reactions

      attacker = Player.where(:id => params.delete(:attacker_id)).first || player
      prevent_react = !!params.delete(:prevent_react)

      attacker.other_players.reverse.each do |ply|
        local_parent = parent_act

        if add_attack
          local_param_string = param_string.dup

          if (attack_state.andand.include? ply.id)
            local_param_string = [local_param_string, *attack_state[ply.id].map {|k,v| "#{k}=#{v}"}].join(';')
          end

          local_parent = parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}" +
                                                                        "_doattack;" +
                                                                        "target=#{ply.id};" +
                                                                        "source=#{attacker.id}" +
                                                                        local_param_string,
                                                    :game => game)
        end

        react_to = attack_act || local_parent

        if add_react && !prevent_react
          # Handle automoating here. If the attacked player has a Moat in hand
          # and Automoat enabled, call Moat.react. If they have no other reaction,
          # also suppress the "react" action.
          moat = ply.cards.hand.of_type("BaseGame::Moat")
          non_moat_reaction = ply.cards.hand.any? {|card| (card.is_reaction? &&
                                                            card.react_trigger == :attack &&
                                                            (card.class != BaseGame::Moat))}

          # Also lighthouses (which are always automatic, but the player can still play other reactions)
          lighthouse = ply.cards.enduring.of_type("Seaside::Lighthouse")

          if !lighthouse.empty?
            # Code copied from moat
            # Note - we can still auto from here, though we won't use a moat if
            # the lighthouse has already defended.
            game.histories.create(:event => "#{ply.name} has a lighthouse in play, negating the attack",
                                  :css_class => "player#{ply.seat} play_reaction")
            moat_attack(react_to, ply)
          else
            # Automoat if we can
            if ply.settings.automoat && !moat.empty?
              moat[0].react(react_to, local_parent)
            end
          end

          if ( !ply.settings.automoat ) || non_moat_reaction
            # If we're NOT automoating, or there are non-moats to select
            # then go ahead and offer them to the player
            react_act = local_parent.children.create(:expected_action => "resolve_#{self.class}#{id}_react",
                                                     :text => "React to #{self.class.readable_name}",
                                                     :player => ply,
                                                     :game => game)
          end
        end

        if self.class.order_relevant && instance_exec(params, &self.class.order_relevant)
          # Players need to be attacked in order, so update parent_act
          parent_act = local_parent
        end
      end

      if add_attack && self.class.affects_attacker
        # Attack also affects the attacker. Create the attack action for the attacker themself (e.g, Spy)
        parent_act.children.create(:expected_action => "resolve_#{self.class}#{id}" +
                                                       "_doattack;" +
                                                       "target=#{attacker.id};" +
                                                       "source=#{attacker.id}",
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

    def doreact(journal)
      # This is at the scope of the attackees - and is registering a Reaction
      # We expect to have been passed either :nil_action or a :card_index
      return unless journal.card

      journal.card.react(journal)
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
