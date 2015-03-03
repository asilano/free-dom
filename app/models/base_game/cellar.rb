class BaseGame::Cellar < Card
  costs 2
  action
  card_text "Action (cost: 2) - +1 Action. Discard any number of cards. Draw 1 card " +
                       "per card discarded."

  def play(parent_act)
    super

    # Grant the player another action, and take note of it
    parent_act = player.add_actions(1, parent_act)

    # Now add an action to discard any number of cards
    act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                     :text => "Discard any number of cards, with Cellar")
    act.player = player
    act.game = game
    act.save!

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      controls[:hand] += [{:type => :checkboxes,
                           :action => :resolve,
                           :name => "discard",
                           :choice_text => "Discard",
                           :button_text => "Discard selected",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.hand.size
                          }]
    end
  end

  resolves(:discard).validating_param_is_card_array(:discard, scope: :hand).with do
    # Looks good.
    if !params.include? :discard
      # Nothing to do but create a log
      game.histories.create!(:event => "#{actor.name} discarded no cards to Cellar.",
                            :css_class => "player#{actor.seat} card_discard")
    else
      # Queue up the draw action in case discarding causes anything to trigger
      # (I'm looking at you, Hinterlands::Tunnel)
      Game.parent_act = parent_act.children.create!(
              :expected_action => "resolve_#{self.class}#{id}_draw_n;num=#{params[:discard].length}",
              :game => game)

      # Discard each selected card, taking note of its class for logging purposes
      cards_discarded = []
      cards_chosen = params[:discard].map { |ix| actor.cards.hand[ix.to_i] }
      cards_chosen.each do |card|
        card.discard
        cards_discarded << card.class.readable_name
      end

      # Log the discards
      game.histories.create!(:event => "#{actor.name} discarded #{cards_discarded.join(', ')} with Cellar.",
                            :css_class => "player#{actor.seat} card_discard")
    end

    return "OK"
  end

  def draw_n(params)
    # Draw the same number of replacement cards
    player.draw_cards(params[:num].to_i)
  end
end
