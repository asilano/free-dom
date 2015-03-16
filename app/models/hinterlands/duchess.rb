class Hinterlands::Duchess < Card
  action
  costs 2
  card_text "Action (cost: 2) - +2 Cash. Each player (including you) looks at the top card of his deck, and discards it or puts it back. / When you gain a Duchy, you may gain a Duchess."

  def play(parent_act)
    super

    player.add_cash(2)

    # Have everyone peek at their top card; if there is one, ask about it
    game.players.each do |ply|
      seen = ply.peek_at_deck(1, :top).length

      if (seen > 0)
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose",
                                    :text => "Choose whether to discard the seen card, with #{self}",
                                    :player => ply,
                                    :game => game)
      end
    end

    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "choose"
      controls[:player] += [{:type => :buttons,
                             :label => "#{readable_name}:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"},
                             :options => [{:text => "Discard #{player.cards.deck[0]} from deck",
                                           :choice => "discard"},
                                          {:text => "Leave #{player.cards.deck[0]} on deck",
                                           :choice => "leave"}]
                            }]
    when "gain"
      controls[:player] += [{:type => :buttons,
                             :label => "Buying #{BasicCards::Duchy.readable_name}:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "gain"},
                             :options => [{:text => "Gain a Duchess",
                                           :choice => "accept"},
                                          {:text => "Don't gain a Duchess",
                                           :choice => "decline"}]
                            }]
    end
  end

  resolves(:choose).validating_params_has(:choice).
                    validating_param_value_in(:choice, 'discard', 'leave').
                    with do
    # Everything looks fine. Carry out the requested choice
    card = actor.cards.deck(true)[0]
    if params[:choice] == "leave"
      # Chose not to discard the card, so a no-op other than unpeeking.
      card.peeked = false
      card.save!

      # Create a history
      game.histories.create!(:event => "#{actor.name} chose not to discard the card on the top of their deck.",
                            :css_class => "player#{actor.seat}")

    else
      # Discard the card. It will become unpeeked due to zone change
      card.discard

      # And create a history
      game.histories.create!(:event => "#{actor.name} discarded #{card} from their deck.",
                              :css_class => "player#{actor.seat} card_discard")
    end

    "OK"
  end

  def self.witness_gain(params)
    ply = params[:gainer]
    card = params[:card]
    parent_act = params[:parent_act]
    game = ply.game

    duchess = game.cards.pile.of_type(self.to_s).first
    if duchess && card.class == BasicCards::Duchy
      # Game has Duchesses still in the pile, so once the primary gain is complete,
      # we need to work out if the player wants one
      if ply.settings.autoduchess == Settings::ALWAYS
        # Player is always taking Duchessess
        duchess.resolve_gain(ply, {:choice => "accept"}, parent_act)
      elsif ply.settings.autoduchess == Settings::NEVER
        # Player is never taking Duchessess. Still call resolve_gain, so we get the log
        duchess.resolve_gain(ply, {:choice => "decline"}, parent_act)
      else
        parent_act.children.create!(:expected_action => "resolve_#{self}#{duchess.id}_gain",
                                    :text => "Choose whether to gain a #{duchess}",
                                    :player => ply,
                                    :game => game)
      end
    end

    # Asking about the Duchess doesn't affect the Duchy's gain in any way.
    return false
  end

  resolves(:gain).validating_params_has(:choice).
                  validating_param_value_in('accept', 'decline').
                  with do
    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "decline"
       # Chose not to gain a Duchess. Just log
       game.histories.create!(:event => "#{actor.name} chose not to gain a #{readable_name}.",
                              :css_class => "player#{actor.seat}")
    else
      # Gain a Duchess
      game.histories.create!(:event => "#{actor.name} chose to gain a #{readable_name}.",
                             :css_class => "player#{actor.seat} card_gain")
      duchess_pile = game.piles.find_by_card_type("Hinterlands::Duchess")
      actor.gain(parent_act, :pile => duchess_pile)
    end

    "OK"
  end
end