module GameEngine
  module Cornucopia
    class Menagerie < Card
      text "+1 Action",
           "Reveal your hand. If the revealed cards all have different names, +3 Cards. Otherwise, +1 Card."
      action
      costs 3

      def play(played_by:)
        played_by.grant_actions 1
        hand_cards = played_by.reveal_cards(:all, from: :hand)
        unique = hand_cards.map(&:class).then { |klasses| klasses.length == klasses.uniq.length }
        hand_cards.each do |card|
          card.be_unrevealed if card.revealed
        end

        played_by.draw_cards(unique ? 3 : 1)
      end
    end
  end
end
