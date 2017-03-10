class BaseGame::Militia < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - +2 Cash. Each other player discards down " +
                                        "to 3 cards."

  DiscardEventTempl = Journal::Template.new("{{player}} discarded {{cards}} with #{readable_name}.")

  def play
    super

    # Grant the player 2 cash
    player.cash += 2

    # Then conduct the attack
    attack
  end

  def determine_controls(actor, controls, question)
    #determine_react_controls(player, controls, substep, params)

    case question.method
    when :resolve_discard
      # This is the target choosing all cards to discard
      controls[:hand] += [{:type => :checkboxes,
                           :name => "discard",
                           :choice_text => "Discard",
                           :button_text => "Discard selected",
                           journal_template: DiscardEventTempl.fill(player: actor.name),
                           journals: actor.cards.hand.each_with_index.map { |c, ix| "#{c.readable_name} (#{ix})" },
                           field_name: :cards,
                           if_empty: {cards: 'nothing'},
                           validate: {count: actor.cards.hand.length - 3}
                          }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to discard
    # enough cards to reduce their hand to 3.
    target = Player.find(params[:target])

    # Determine how many cards to discard - never negative
    num_discards = [0, target.cards.hand.size - 3].max
    if num_discards == 0
      return
    end

    game.ask_question(object: self, actor: target,
                      method: :resolve_discard,
                      text: "Discard #{num_discards} #{'card'.pluralize(num_discards)} with #{readable_name}.")
  end

  resolves(:discard).using(DiscardEventTempl).
                      validating_param_is_card_array(:cards, scope: :hand,
                                                      count: -> journal { journal.actor.cards.hand.length - 3 } ).with do
    # Looks good.
    if !journal.cards.empty?
      # Discard each selected card
      journal.cards.each(&:discard)
    end
  end
end
