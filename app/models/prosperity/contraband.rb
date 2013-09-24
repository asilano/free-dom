# Contraband (Treasure - $5) - 3 Cash, +1 Buy. When you play this, the player to your left names a card. You can't buy that card this turn.

class Prosperity::Contraband < Card
  costs 5
  treasure :special => true
  card_text "Treasure (Cost: 5) - 3 Cash, +1 Buy. When you play this, the next player names a card. You can't buy that card this turn."

  def play_treasure(parent_act)
    super

    player.cash += 3
    player.save!
    parent_act = player.add_buys(1, parent_act)

    # Queue up an action for the next player to ban a card.
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_ban",
                               :text => "Ban #{player.name} from buying a card",
                               :player => player.next_player,
                               :game => game)

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "ban"
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Ban this",
                            :nil_action => "Ban '#{Card.non_card}'",
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "ban"},
                            :piles => [true] * game.piles.size
                          }]
    end
  end

  def resolve_ban(ply, params, parent_act)
    # We expect to have been passed a :pile_index or :nil_action
    if not params.include? :pile_index and not params.include? :nil_action
      return "Invalid parameters"
    end

    # Check that the pile is in range
    if ((params.include? :pile_index) and
           (params[:pile_index].to_i < 0 or
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to name an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    end

    if params.include? :nil_action
      # Player named a nonsense card.
      game.histories.create!(:event => "#{ply.name} banned #{params[:nil_action].match(/Ban '(.*)'/)[1]}.",
                            :css_class => "player#{ply.seat}")
    else
      # Player has named a card. Write the name to the game's facts. It will be used in Player#determine_controls
      # for the Buy action.
      pile = game.piles[params[:pile_index].to_i]
      game.facts_will_change!
      game.facts[:contraband] ||= []
      game.facts[:contraband] << pile.card_type
      game.save!

      game.histories.create!(:event => "#{ply.name} banned '#{pile.card_type.readable_name}'.",
                            :css_class => "player#{ply.seat}")
    end

    return "OK"
  end
end