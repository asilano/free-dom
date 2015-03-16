class Hinterlands::Scheme < Card
  action
  costs 3
  card_text "Action (cost: 3) - Draw 1 card, +1 Action. At the start of Clean-up this turn, " +
            "you may choose an Action card you have in play. If you discard it from play this turn, put it on your deck."

  def play(parent_act)
    super

    # Simple stuff happens here
    player.draw_cards(1)
    player.add_actions(1, parent_act)


    # Add an action to return a card, just before end-of-turn processing
    game.root_action.insert_child!(:expected_action => "resolve_#{self.class}#{id}_trigger",
                                   :game => game)

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "return"
      controls[:play] += [{:type => :button,
                           :action => :resolve,
                           :text => "Choose",
                           :nil_action => "Choose nothing",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "return"},
                           :cards => player.cards.in_play.map do |card|
                             card.is_action?
                           end
                          }]
    end
  end

  def trigger(params)
    parent_act = params[:parent_act]

    # Check if we can handle this automatically
    if player.cards.in_play.none? {|c| c.is_action?}
      # No action cards in play. Odd, but hey. Just log and return
      game.histories.create!(:event => "#{player.name} had nothing to return with #{self}",
                             :css_class => "player#{player.seat}")
    elsif player.settings.autoscheme && player.cards.in_play.none? {|c| c.is_action? && c.class != self.class}
      # Autoscheme is on, and only Schemes are in play. Call resolve directly
      ix = player.cards.in_play.index {|c| c.class == self.class}
      return resolve_return(player, {:card_index => ix}, parent_act)
    else
      # Player has an actual choice to make
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_return",
                                  :text => "Choose an Action card to return with Scheme",
                                  :player => player,
                                  :game => game)
    end

    return "OK"
  end

  resolves(:return).validating_params_has_any_of(:nil_action, :card_index).
                    validating_param_is_card(:card_index, scope: :in_play, &:is_action?).
                    with do
    if params.include? :nil_action
      # Not returning anything; just log
      game.histories.create(:event => "#{actor.name} chose not to return anything with #{self}",
                            :css_class => "player#{actor.seat}")

      return "OK"
    end

    # Put the chosen card on top of the deck
    card = actor.cards.in_play[params[:card_index].to_i]
    card.location = "deck"
    card.position = -1
    card.save!

    game.histories.create(:event => "#{actor.name} put #{card} on top of their deck with #{self}",
                          :css_class => "player#{actor.seat}")

    "OK"
  end
end
