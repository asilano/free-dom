class Hinterlands::Tunnel < Card
  costs 3
  victory :points => 2
  reaction :to => :discard
  pile_size {|num_players|  case num_players
                            when 1..2
                              8
                            when 3..6
                              12
                            end}

  card_text "Reaction/Victory (cost: 3) - " +
            "When you discard this other than during a Clean-up phase, you may reveal it. If you do, gain a Gold." +
            " / 2 points"

  # Override Card#discard to handle the Gold-giving
  def discard
    super

    parent_act = Game.parent_act

    # Skip acting if this is the clean-up phase
    unless game.turn_phase == Game::TurnPhases::CLEAN_UP
      if player.settings.autotunnel == Settings::ASK
        # Enquire if the user wants the gold
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                    :text => "Choose whether to gain a Gold from #{self}",
                                    :player => player,
                                    :game => game)
      elsif player.settings.autotunnel == Settings::ALWAYS
        # Just give the gold without question
        resolve_choose(player, {:choice => 'yes'}, parent_act)
      else
        # Never giving Gold. Silently do nothing
      end
    end
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "choose"
      controls[:player] += [{:type => :buttons,
                             :label => "Gain a Gold?",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"},
                             :options => [{:text => "Gain a Gold",
                                           :choice => "yes"},
                                          {:text => "Don't gain a Gold",
                                           :choice => "no"}]
                            }]
    end
  end

  resolves(:choose).validating_params_has(:choice).
                    validating_param_value_in(:choice, 'yes', 'no').
                    with do
    if params[:choice] == "yes"
      # Player chose to gain a Gold
      gold_pile = game.piles.find_by_card_type("BasicCards::Gold")

      game.histories.create!(:event => "#{actor.name} discarded Tunnel, and gained a Gold.",
                             :css_class => "player#{actor.seat} card_gain")

      actor.gain(parent_act, :pile => gold_pile)
    else
      # Player chose not to gain a gold. Don't log - discards are private.
    end

    "OK"
  end
end