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

  resolves(:ban).validating_params_has_any_of(:pile_index, :nil_action).
                  validating_param_is_pile(:pile_index).
                  with do
    if params.include?(:nil_action)
      # Player named a nonsense card.
      game.histories.create!(:event => "#{actor.name} banned #{params[:nil_action].match(/Ban '(.*)'/)[1]}.",
                            :css_class => "player#{actor.seat}")
    else
      # Player has named a card. Write the name to the game's facts. It will be used in Player#determine_controls
      # for the Buy action.
      pile = game.piles[params[:pile_index].to_i]
      game.facts_will_change!
      game.facts[:contraband] ||= []
      game.facts[:contraband] << pile.card_type
      game.save!

      game.histories.create!(:event => "#{actor.name} banned '#{pile.card_type.readable_name}'.",
                            :css_class => "player#{actor.seat}")
    end

    return "OK"
  end
end