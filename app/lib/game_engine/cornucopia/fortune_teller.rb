module GameEngine
  module Cornucopia
    class FortuneTeller < Card
      text "+$2",
           "Each other player reveals cards from the top of their deck until they reveal " \
           "a Victory card or a Curse. They put it on top and discard the rest."
      action
      attack
      costs 3

      def play(played_by:)
        played_by.cash += 2
        launch_attack(victims: played_by.other_players)
      end

      def attack(victim:)
        cards_revealed = victim.reveal_cards_until(from: :deck) do |card, _|
          card.victory? || card.curse?
        end

        for_discard, for_replace = if cards_revealed.last.victory? || cards_revealed.last.curse?
          [cards_revealed[0..-2], cards_revealed.last]
        else
          [cards_revealed, nil]
        end

        game.current_journal.histories << History.new(
          "#{victim.name} discarded #{for_discard.map(&:readable_name).join(', ')} from their deck.",
          player: victim,
          css_classes: %w[discard-card])

        for_discard.each(&:discard)

        return unless for_replace

        game.current_journal.histories << History.new(
          "#{victim.name} put #{for_replace.readable_name} on top of their deck.",
          player: victim,
          css_classes: %w[place-card])
        for_replace.be_unrevealed
      end
    end
  end
end
