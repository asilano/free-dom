module GameEngine
  module Cornucopia
    class FarmingVillage < Card
      text "+2 Actions",
           "Reveal cards from your deck until you reveal a Treasure or Action card. " +
           "Put that card into your hand and discard the rest."
      action
      costs 4

      def play(played_by:)
        played_by.grant_actions 2

        cards_revealed = played_by.reveal_cards_until(from: :deck) do |card, _|
          card.treasure? || card.action?
        end

        for_discard, for_hand = if cards_revealed.last.treasure? || cards_revealed.last.action?
          [cards_revealed[0..-2], cards_revealed.last]
        else
          [cards_revealed, nil]
        end

        game.current_journal.histories << History.new(
          "#{played_by.name} discarded #{for_discard.map(&:readable_name).join(', ')} from their deck.",
          player: played_by,
          css_classes: %w[discard-card])

        for_discard.each(&:discard)

        return unless for_hand

        game.current_journal.histories << History.new(
          "#{played_by.name} put #{for_hand.readable_name} into their hand.",
          player: played_by,
          css_classes: %w[move-card])
        for_hand.move_to_hand
      end
    end
  end
end
