class BaseGame::Mine < Card
  costs 5
  action
  card_text "Action (cost: 5) - Trash a Treasure card from your hand. " +
                       "Gain a Treasure card costing up to 3 more, and put " +
                       "it into your hand."

  module Journals
    class TrashJournal < Journal
      causes :trash_treasure
      validates_hash_keys :parameters do
        validates :card_id, card: { owner: :actor, location: :hand, satisfies: :is_treasure? }
      end
      text do
        "#{player.name} chose #{card.readable_name} to trash with Mine."
      end
      question(text: 'Trash a card with Mine') do
        {
          hand: {
            type: :button,
            text: 'Trash',
            parameters: cards.hand.map { |c| c.id if c.is_treasure? }
          }
        }
      end
    end

    class TakeJournal < Journal
      causes :take_treasure
      validates_hash_keys :parameters do
        validates :card_id, card: { location: :pile, allow_nil: false,
                                    satisfies: ->(card, journal){ card.position == 0 && card.cost <= journal.parameters[:max_cost].to_i },
                                    satisfy_msg: 'is not an affordable card on top of a pile.' }
      end
      text { "#{player.name} took #{card.readable_name} with Mine." }
      question(attribs: :max_cost, text: 'Take a replacement card with Mine') do |q|
        {
          piles: {
            type: :button,
            text: 'Take',
            expect: { max_cost: q.max_cost },
            parameters: game.piles.map { |p| c = p.cards.first; c.id if c && c.is_treasure? && c.cost <= q.max_cost }
          }
        }
      end
    end
  end

  def play
    super

    if player.cards.hand.none?(&:is_treasure?)
      # Holding no treasure cards. Just log
      game.add_history(event: "#{player.name} trashed nothing.",
                       css_class: "player#{player.seat} card_trash")
      return
    end

    # Ask the required question
    q = game.ask_question(object: self, actor: player, journal: Journals::TrashJournal)

    return if game.find_journal(q[:template])
    return unless player.cards.hand.select(&:is_treasure?).map(&:class).uniq.length == 1

    # Only holding one type of treasure card. Pre-create the journal
    treasure = player.cards.hand.detect(&:is_treasure?)
    game.add_journal(type: Journals::TrashJournal.to_s,
                     player: player,
                     parameters: { card_id: treasure.id })
  end

  def trash_treasure(journal)
    # Trash the selected card, and create a new question for picking up
    # the Mined card.
    journal.card.trash
    trashed_cost = journal.card.cost
    game.add_history(event: "#{journal.player.name} trashed a #{journal.card.readable_name} from hand (cost: #{trashed_cost}).",
                     css_class: "player#{journal.player.seat} card_trash")

    candidates = game.piles.select do |pile|
      pile.cost <= (trashed_cost + 3) && pile.card_class.is_treasure? && !pile.cards.empty?
    end

    if candidates.empty?
      # Can't take a replacement. Just log.
      game.add_history(event: "#{journal.player.name} couldn't take a card with #{readable_name}.",
                       css_class: "player#{journal.player.seat} card_take")
      return
    end

    q = game.ask_question(object: self, actor: journal.player, journal: Journals::TakeJournal, expect: { max_cost: trashed_cost + 3 })

    if !game.find_journal(q[:template]) && candidates.length == 1
      # Only one option. Fabricate the journal.
      game.add_journal(type: Journals::TakeJournal,
                       player: player,
                       parameters: { card_id: pile.cards.first.id })
    end
  end

  def take_treasure(journal)
    # Process the take.
    journal.player.gain(journal.card, journal, location: 'hand')
  end
end
