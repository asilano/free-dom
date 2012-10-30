class Hinterlands::Duchess < Card
  action
  costs 2
  card_text "+2 Cash. Each player (including you) looks at the top card of his deck, and discards it or puts it back. / When you gain a Duchy, you may gain a Duchess."

  # The gain hook is located in Player#gain. It's processed in Duchess#resolve_gain, below.

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

  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, either "discard" or "leave"
    if (not params.include? :choice) or
       (not params[:choice].in? ["discard", "leave"])
      return "Invalid parameters"
    end

    # Everything looks fine. Carry out the requested choice
    card = ply.cards.deck(true)[0]
    if params[:choice] == "leave"
      # Chose not to discard the card, so a no-op other than unpeeking.
      card.peeked = false
      card.save!

      # Create a history
      game.histories.create!(:event => "#{ply.name} chose not to discard the card on the top of their deck.",
                            :css_class => "player#{ply.seat}")

    else
      # Discard the card. It will become unpeeked due to zone change
      card.discard

      # And create a history
      game.histories.create!(:event => "#{ply.name} discarded #{card} from their deck.",
                              :css_class => "player#{ply.seat} card_discard")
    end

    return "OK"

  end

  def resolve_gain(ply, params, parent_act)
    # We expect to have a :choice parameter, either "accept" or "decline"
    if (not params.include? :choice) or
       (not params[:choice].in? ["accept", "decline"])
      return "Invalid parameters"
    end

    # Everything looks fine. Carry out the requested choice
    if params[:choice] == "decline"
       # Chose not to gain a Duchess. Just log
       game.histories.create!(:event => "#{ply.name} chose not to gain a #{readable_name}.",
                              :css_class => "player#{ply.seat}")
    else
      # Gain a Duchess
      game.histories.create!(:event => "#{ply.name} chose to gain a #{readable_name}.",
                             :css_class => "player#{ply.seat} card_gain")
      duchess_pile = game.piles.find_by_card_type("Hinterlands::Duchess")
      ply.gain(parent_act, duchess_pile.id)
    end
  end
end