class BaseGame::Library < Card
  costs 5
  action
  card_text "Action (cost: 5) - Draw until you have 7 cards in hand. You may set " +
                       "aside any Action cards you draw this way, as you " +
                       "draw them; discard the set-aside cards after you " +
                       "finish drawing."

  attr_reader :last_visible_journal

  module Journals
    class SetAsideJournal < Journal
      causes :set_aside
      validates_hash_keys :parameters do
        validates :nil_action, presence: { if: ->(p) { p[:card_id].blank? } }
        validates :nil_action, absence: { unless: ->(p) { p[:card_id].blank? } }
        validates :card_id, card: { owner: :actor,
                                    location: :hand,
                                    satisfies: ->(c, _) { c == c.player.cards.hand.select(&:is_action?).last },
                                    allow_nil: true }
      end
      before_save :make_hidden

      text do
        card = game.find_card(parameters[:card_id])
        if card
          "#{player.name} set #{card.readable_name} aside."
        else
          nil_text = parameters[:nil_action]
          "#{player.name} kept #{parameters[:nil_action].sub(/^Keep /, '')}."
        end
      end
      question(text: 'Set aside or keep a card with Library') do
        {
          hand: {
            type: :button,
            text: 'Set aside',
            nil_action: { text: "Keep #{cards.hand.last.readable_name}" },
            parameters: ([nil] * (cards.hand.size - 1)) + [cards.hand.last.id]
          }
        }
      end

      def make_hidden
        self.hidden = true if parameters[:nil_action]
      end
    end
  end

  def play
    super

    @last_visible_journal = game.current_journal
    # Library is heavily re-entrant, so we'll put its processing in a "clean"
    # subfunction
    process
  end

  # Function to handle the actions dictated by Library. Expected to be called
  # by both play() and resolve_choice()
  def process
    # Assume we're just going to draw up to 7 cards; we'll break out of the loop
    # if we hit an action
    num_to_draw = 7 - player.cards.hand.size

    1.upto(num_to_draw) do
      drawn = player.draw_cards(1, journal: @last_visible_journal)

      # If we didn't actually draw a card - so deck and discard are empty - give
      # up (or we'd just loop a bit more than we want).
      if drawn.length == 0
        discard_set_aside
        return
      end

      if drawn[0].is_action?
        # Drawn an action. Ask whether we should set this card aside.
        game.ask_question(object: self, actor: player, journal: Journals::SetAsideJournal)
        return
      end
    end

    discard_set_aside
  end

  def determine_controls(actor, controls, question)
    case question.method
    when :resolve_choose
      # Player deciding whether to keep or set aside a drawn action.
      # Technically, this would make sense as a Radio Button control - but that
      # needs two clicks, and is likely to get irritating.
      last_card = actor.cards.hand.last
      last_ix = actor.cards.hand.length - 1
      controls[:hand] += [{:type => :button,
                          :text => "Set aside",
                          :nil_action => [{text: "Keep",
                                           journal: "#{actor.name} chose 'keep' for #{last_card.readable_name} (#{last_ix}) with #{readable_name}.",
                                           hidden: true}],
                          :journals => ([nil] * (player.cards.hand.size - 1)) +
                                       ["#{actor.name} chose 'set aside' for #{last_card.readable_name} (#{last_ix}) with #{readable_name}."]
                         }]
    end
  end

  def set_aside(journal)
    if journal.card
      card = journal.card
      card.location = "library"
      card.revealed = true
      @last_visible_journal = journal
    end

    # Carry on processing
    process
  end

  def discard_set_aside
    # Move all revealed cards to Discard, and unreveal them
    player.cards.revealed.each do |card|
      card.discard
    end
  end

end
