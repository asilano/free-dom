class BaseGame::Bureaucrat < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - Gain a Silver card; put it on top of your deck. " +
                               "Each other player reveals a Victory card from " +
                               "his or her hand and puts it on top of their " +
                               "deck, or reveals a hand with no Victory cards."

  def play(parent_act)
    super

    # First, acquire a Silver to top of deck.
    silver_pile = game.piles.find_by_card_type("BasicCards::Silver")
    player.gain(parent_act, :pile => silver_pile, :location => "deck")

    game.histories.create!(:event => "#{player.name} gained a Silver to top of their deck.",
                          :css_class => "player#{player.seat} card_gain")

    # Now, attack
    attack(parent_act)
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "victory"
      # Ask the attack target for a Victory card, or to reveal a hand devoid of
      # all such.
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :text => "Place",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "victory"},
                           :cards => player.cards.hand.map {|c| c.is_victory? }
                          }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to put a Victory
    # card on top of their deck.
    target = Player.find(params[:target])
    # source = Player.find(params[:source])
    parent_act = params[:parent_act]

    # Handle autocratting
    target_victories = target.cards.hand(true).select {|c| c.is_victory?}

    if (target.settings.autocrat_victory &&
        target_victories.map {|c| c.class}.uniq.length == 1)
      # Target is autocratting victories, and holding exactly one type of
      # victory card. Find the index of that card, and call resolve_victory
      vic = target_victories[0]
      index = target.cards.hand.index(vic)
      return resolve_victory(target, {:card_index => index}, parent_act)
    elsif target_victories.empty?
      # Target is holding no victories. Call resolve_victory for the nil_action
      return resolve_victory(target, {:nil_action => true}, parent_act)
    else
      # Autocrat doesn't apply. Create the pending action to request the Victory
      # card
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_victory",
                                 :text => "Place a Victory card onto deck",
                                 :player => target,
                                 :game => game)
    end

    return "OK"
  end

  # This is at the attack target either putting a card back on their deck,
  # or revealing a hand devoid of victory cards.
  resolves(:victory).validating_params_has_any_of(:nil_action, :card_index).
                     validating_param_is_card(:card_index, scope: :hand, &:is_victory?).
                     validating_param_present_only_if(:nil_action, description: 'you have no victory cards in hand') do
                       !actor.cards.hand.any?(&:is_victory?)
                     end.with do
    # All looks good - process the request
    if params.include? :nil_action
      # :nil_action specified. "Reveal" the player's hand. Since no-one needs to
      # act on the revealed cards, just add a history entry detailing them.
      game.histories.create!(:event => "#{actor.name} revealed their hand to the Bureaucrat:",
                            :css_class => "player#{actor.seat} card_reveal")
      game.histories.create!(:event => "#{actor.name} revealed #{actor.cards.hand.map {|c| c.class.readable_name}.join(', ')}.",
                            :css_class => "player#{actor.seat} card_reveal")
    else
      # :card_index specified. Place the specified card on top of the player's
      # deck, and "reveal" it by creating a history.
      card = actor.cards.hand[params[:card_index].to_i]
      card.location = "deck"
      card.position = -1
      card.save!
      actor.renum(:deck)
      game.histories.create!(:event => "#{actor.name} put a #{card.class.readable_name} on top of their deck.",
                            :css_class => "player#{actor.seat}")
    end

    "OK"
  end
end
