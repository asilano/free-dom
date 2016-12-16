class BaseGame::Mine < Card
  costs 5
  action
  card_text "Action (cost: 5) - Trash a Treasure card from your hand. " +
                       "Gain a Treasure card costing up to 3 more, and put " +
                       "it into your hand."

  TrashEventTempl = Journal::Template.new("{{player}} chose {{card}} to trash with #{readable_name}.")
  TakeEventTempl = Journal::Template.new("{{player}} took {{supply_card}} with #{readable_name}.")

  def play
    super

    journal = game.find_journal(TrashEventTempl)

    if journal.nil?
      if player.cards.hand.select(&:is_treasure?).map(&:class).uniq.length == 1
        # Only holding one type of treasure card. Pre-create the journal
        ix = player.cards.hand.index(&:is_treasure?)
        journal = game.add_journal(player_id: player.id,
                                    event: TrashEventTempl.fill(player: player.name, card: "#{player.cards.hand[ix].readable_name} (#{ix})"))
      elsif !(player.cards.hand.any? {|c| c.is_treasure?})
        # Holding no treasure cards. Just log
        game.add_history(:event => "#{player.name} trashed nothing.",
                          :css_class => "player#{player.seat} card_trash")
      else
        # Ask the required question, and escape this processing stack
        game.ask_question(object: self, actor: player, method: :resolve_trash, text: "Trash a card with #{readable_name}.")
        game.abort_journal
      end
    end

    if journal
      resolve_trash(journal, player)
    end
  end

  def determine_controls(actor, controls, question)
    case question.method
    when :resolve_trash
      controls[:hand] += [{:type => :button,
                          :text => "Trash",
                          :nil_action => nil,
                          journals: actor.cards.hand.each_with_index.map do |c, ix|
                            TrashEventTempl.fill(player: actor.name, card: "#{c.readable_name} (#{ix})") if c.is_treasure?
                          end
                         }]
    when :resolve_take
      controls[:piles] += [{:type => :button,
                            :text => "Take",
                            :nil_action => nil,
                            journals: game.piles.each_with_index.map do |pile, ix|
                              if (pile.cost <= (question.params[:trashed_cost].to_i + 3) &&
                                   pile.card_class.is_treasure? &&
                                   !pile.cards.empty?)
                                TakeEventTempl.fill(player: actor.name, supply_card: "#{pile.cards[0].readable_name} (#{ix})")
                              end
                            end
                          }]
    end
  end

  resolves(:trash).using(TrashEventTempl).
                   validating_param_is_card(:card, scope: :hand, &:is_treasure?).
                   with do
    # Trash the selected card, and create a new question for picking up
    # the Mined card.
    journal.card.trash
    trashed_cost = journal.card.cost
    journal.add_history(:event => "#{actor.name} trashed a #{journal.card.readable_name} from hand (cost: #{trashed_cost}).",
                        :css_class => "player#{actor.seat} card_trash")

    take_journal = game.find_journal(TakeEventTempl)

    if !take_journal
      candidates = game.piles.map.with_index do |pile, ix|
        if (pile.cost <= (trashed_cost + 3) &&
                          pile.card_class.is_treasure? &&
                          !pile.cards.empty?)
          [pile, ix]
        else
          nil
        end
      end.compact

      if candidates.length == 0
        # Can't take a replacement. Just log.
        game.add_history(:event => "#{player.name} couldn't take a card with #{readable_name}.",
                          :css_class => "player#{player.seat} card_take")
      elsif candidates.length == 1
        # Only one option. Fabricate the journal.
        take_journal = game.add_journal(player_id: player.id,
                                    event: TakeEventTempl.fill(player: player.name,
                                     supply_card: "#{candidates[0][0].readable_name} (#{candidates[0][1]})"))
      else
        game.ask_question(object: self, actor: actor,
                          method: :resolve_take,
                          text: "Take a replacement card with #{readable_name}.",
                          params: {trashed_cost: trashed_cost})
        game.abort_journal
      end
    end

    if take_journal
      take_journal.params = {trashed_cost: trashed_cost}
      resolve_take(take_journal, actor)
    end
  end

  resolves(:take).using(TakeEventTempl).
                  validating_param_is_card(:supply_card, scope: :supply) { is_treasure? &&
                                                                            cost <= my{journal.params}[:trashed_cost].to_i + 3 }.
                  with do
    # Process the take.
    actor.gain(:card => journal.supply_card, :location => "hand", journal: journal)
  end
end
