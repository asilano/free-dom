# Watchtower (Action - Reaction - $3) - Draw until you have 6 cards in hand. / When you gain a card, you may reveal this from your hand. If you do, either trash that card, or put it on top of your deck.

class Prosperity::Watchtower < Card
  action
  reaction :to => :gain
  costs 3
  card_text "Action (Reaction; cost: 3) - Draw until you have 6 cards in hand. / When you gain a card, you may reveal this from your hand. If you do, either trash that card, or put it on top of your deck."

  def play(parent_act)
    super

    num_to_draw = 6 - player.cards.hand(true).count

    if num_to_draw > 0
      player.draw_cards(num_to_draw)
    else
      # Log that the player was already at 6.
      game.histories.create!(:event => "#{player.name} drew no cards from #{self}.",
                            :css_class => "player#{player.seat}")
    end

    return "OK"
  end

  def self.witness_gain(params)
    ply = params[:gainer]
    card = params[:card]
    parent_act = params[:parent_act]
    location = params[:location]
    position = params[:position]

    tower = ply.cards.hand.of_type(to_s)[0]
    if tower
      # Player has a Watchtower in hand, so we need to ask where they want the card.
      parent_act.children.create!(:expected_action => "resolve_#{self}#{tower.id}_choose;" +
                                             "card_id=#{card.id};location=#{location || 'discard'};" +
                                             "position=#{position || 0};gain_id=#{params[:this_act_id]}",
                                  :text => "Decide on destination for #{card}.",
                                  :player => ply,
                                  :game => ply.game)

      # Watchtower prevents the gain from just occurring
      return true
    end

    # No action from tower
    return false
  end

  def determine_controls(ply, controls, substep, params)
    case substep
    when "choose"
      # Reaction controls
      card = Card.find(params[:card_id])
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :label => "Apply #{self} to #{card}?",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "choose"}.merge(params),
                             :options => [{:text => "No - #{card} to #{params[:location]}",
                                           :choice => "normal"},
                                          ({:text => "Yes - #{card} on deck",
                                           :choice => "deck"} unless params[:location] == "deck"),
                                          {:text => "Yes - trash #{card}",
                                           :choice => "trash"}].compact
                            }]
    end
  end

  def resolve_choose(ply, params, parent_act)
    # We expect to have a :choice parameter, either "trash", "deck" or "normal"
    if (not params.include? :choice) or
       (not params[:choice].in? ["trash", "deck", "normal"])
      return "Invalid parameters"
    end

    to_del = game.pending_actions.where(:player_id => ply).select {|pa| pa.expected_action =~ /;gain_id=#{params[:gain_id]}/}

    card = Card.find(params[:card_id])

    if params[:choice] == "normal"
      # If no-one else is trying to replace the gain, perform the default action here.
      if to_del.empty?
        card.gain(ply, parent_act, params[:location], params[:position].to_i)
      end
    else
      # We're replacing the Gain, so scrap any other actions looking to replace it
      to_del.each do |pa|
        raise "Destroying gain replacement action with children" unless pa.children.empty?
        pa.destroy
      end

      if params[:choice] == "deck"
        game.histories.create!(:event => "#{ply.name} reacted with #{self} and placed #{card} on their deck.",
                              :css_class => "player#{ply.seat}")

        # Call Card#gain directly with the stated choice (to avoid an infinite loop!)
        card.gain(ply, parent_act, "deck")
      else
        game.histories.create!(:event => "#{ply.name} reacted with #{self} and trashed #{card}.",
                              :css_class => "player#{ply.seat} card_trash")

        # Trash the card
        card.trash
      end

    end

    return "OK"
  end
end