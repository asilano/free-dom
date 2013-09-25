class Hinterlands::Embassy < Card
  action
  costs 5
  card_text "Action (costs: 5) - Draw 5 cards. Discard 3 cards. / When you gain this, each other player gains a Silver."

  def play(parent_act)
    super

    player.draw_cards(5)

    # If the player has very few cards in deck, it's possible for the draw to fail, and
    # thus there to be fewer than 3 cards available to discard.
    num_discards = [3, player.cards.hand.length].min

    if (0 == num_discards)
      # Just log that we're out of cards
      game.histories.create!(:event => "#{player.name} discarded no cards to #{self}, due to having none.",
                             :css_class => "player#{player.seat} card_discard")
    elsif (num_discards == player.cards.hand.length)
      # Only got as many cards as we need to discard, so discard them all.
      player.cards.hand.each do |card|
        card.discard
        game.histories.create!(:event => "#{player.name} discarded #{card}.",
                               :css_class => "player#{player.seat} card_discard")
      end
    elsif (player.cards.hand.map(&:class).uniq.length == 1)
      # Only one type of card in hand, so discard without question
      (1..num_discards).each do |ix|
        card = player.cards.hand[-ix]
        card.discard
        game.histories.create!(:event => "#{player.name} discarded #{card}.",
                               :css_class => "player#{player.seat} card_discard")
      end
    else
      # Queue up the requests to do the discards
      1.upto(num_discards) do |num|
        parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                                 :text => "Discard #{num} card#{num > 1 ? 's' : ''}",
                                                 :player => player,
                                                 :game => game)
      end
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "discard"
      # This is the target choosing one card to discard
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :text => "Discard",
                           :nil_action => nil,
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => [true] * player.cards.hand.size
                          }]
    end
  end

  def resolve_discard(ply, params, parent_act)
    # We expect to have been passed a :card_index
    if !params.include? :card_index
      return "Invalid parameters"
    end

    # Processing is surprisingly similar to a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to discard an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    end

    # All checks out. Discard the selected card.
    card = ply.cards.hand[params[:card_index].to_i]
    card.discard
    game.histories.create!(:event => "#{ply.name} discarded #{card.class.readable_name}.",
                            :css_class => "player#{ply.seat} card_discard")

    return "OK"
  end

  # Notice a gain event. If it's Embassy itself, grant each other player a Silver.
  def self.witness_gain(params)
    ply = params[:gainer]
    card = params[:card]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card gained is Embassy, and if so give out Silvers
    if card.class == self
      silvers = game.piles.find_by_card_type("BasicCards::Silver")
      ply.other_players.each do |opp|
        opp.gain(parent_act, :pile => silvers)}
        game.histories.create!(:event => "#{opp.name} gained a #{silvers.card_class.readable_name}" +
                                          " from #{ply.name}'s #{readable_name}.",
                               :css_class => "player#{opp.seat} player#{ply.seat} card_gain")
      end
    end

    # Embassy's Silver gains don't affect the gain of Embassy at all
    return false
  end
end