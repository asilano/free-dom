class BaseGame::Thief < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - Each other player reveals the top two cards of his deck. " +
      "If they revealed any Treasure cards, they trash one of them that you choose. " +
      "You may gain any or all of the trashed cards. They discard the other revealed cards."

  def play(parent_act)
    super

    # Just conduct the attack
    attack(parent_act)

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "choose"
      # This is the attacker deciding what to do with the revealed cards from
      # one target
      # We ask for a "2D radio array" - that is, each card has a number of
      # options provided; but only one option /in total/ can be selected
      target = Player.find(params[:target])
      controls[:revealed] += [{:player_id => target.id,
                               :type => :two_d_radio,
                               :action => :resolve,
                               :text => "Confirm",
                               :options => ["Just Trash", "Trash and Take"],
                               :nil_action => nil,
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "choose",
                                           :target => target.id},
                               :cards => target.cards.revealed.map do |card|
                                  card.is_treasure?
                               end
                              }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, reveal the top two cards of
    # the target's deck, and ask the attacker to pick a treasure.
    target = Player.find(params[:target])
    source = Player.find(params[:source])
    parent_act = params[:parent_act]

    # Get the attack target to reveal the top two cards from their deck
    target.reveal_from_deck(2)

    if target.cards.revealed.any? {|c| c.is_treasure?}
      # Hang an action off the parent to ask the attacker to choose a card
      # to trash or take
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose;target=#{target.id}",
                                       :text => "Choose Thief actions for #{target.name}",
                                       :player => source,
                                       :game => game)
    else
      # Neither card is a treasure. Call resolve_choose directly with nil_action
      return resolve_choose(source, {:choice => "nil_action",
                                     :target => target.id},
                            parent_act)
    end

    "OK"
  end

  # This is at the scope of the attacker, and represents their choice of what
  # to do with the revealed cards from each attackee.
  resolves(:choose).prepare_param(:choice) do |value|
                        if value == 'nil_action'
                          params[:nil_action] = true
                        else
                          match = /^([0-9]+)\.([0-9]+)$/.match(value)
                          if match
                            params[:card_index] = match[1]
                            params[:option_index] = match[2]
                          end
                        end
                      end.
                    # Check we have either both card_index and option_index, _or_ :nil_action
                    validating_params_has_any_of([:card_index, :option_index], :nil_action).
                    validating_params_has_any_of(:target).
                    validating_param_is_player(:target).
                    validating_param_present_only_if(:nil_action, description: 'target has no revealed treasures') do
                      Player.find_by_id(params[:target]).cards.revealed.none?(&:is_treasure?)
                    end.
                    validating_param_is_card(:card_index, scope: :revealed, player: :target, &:is_treasure?).
                    validating_param_value_in(:option_index, '0', '1').
                    with do
    target = Player.find(params[:target])
    if params[:choice] == "nil_action"
      # Attacker chose not to trash either card. We'll discard them both below,
      # so just create a history entry here.
      game.histories.create!(:event => "#{actor.name} chose to trash neither of #{target.name}'s cards.",
                            :css_class => "player#{actor.seat} player#{target.seat} card_trash")

      discardrest(params)
    else
      card_index, option_index = [params[:card_index], params[:option_index]].map {|i| i.to_i}

      # Everything checks out. Do the requested action with the specified card.
      card = target.cards.revealed[card_index]
      if option_index == 0
        # Chose to just trash the card.
        game.cards.in_trash(true)
        card.trash
        game.histories.create!(:event => "#{actor.name} chose to trash #{target.name}'s #{card.class.readable_name}.",
                              :css_class => "player#{actor.seat} player#{target.seat} card_trash")

        # And discard the rest
        discardrest(params)
      else
        # Chose to steal the card. Queue an action to discard the other one, then gain the chosen one
        game.histories.create!(:event => "#{actor.name} chose to steal #{target.name}'s #{card.class.readable_name}.",
                              :css_class => "player#{actor.seat} player#{target.seat}")
        new_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discardrest;target=#{target.id}",
                                                 :game => game)
        actor.gain(new_act, :card => card)
      end
    end

    "OK"
  end

  def discardrest(params)
    # Discard the remaining cards.
    target = Player.find(params[:target])
    target.cards.revealed.each do |c|
      c.discard
    end
    game.histories.create!(:event => "#{target.name} discarded the remaining revealed cards.",
                          :css_class => "player#{target.seat} card_discard")

    "OK"
  end
end
