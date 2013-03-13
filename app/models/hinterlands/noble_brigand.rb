class Hinterlands::NobleBrigand < Card
  action :attack => true
  costs 4
  card_text "+1 Coin / When you buy this or play it, each other player reveals the top 2 cards of his deck, " +
            "trashes a revealed Silver or Gold you choose, and discards the rest. " +
            "If he didn't reveal a Treasure, he gains a Copper. You gain the trashed cards."
end