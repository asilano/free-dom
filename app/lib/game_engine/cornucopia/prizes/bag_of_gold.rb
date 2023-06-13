module GameEngine
  module Cornucopia
    module Prizes
      class BagOfGold < Card
        text "+1 Action",
             "Gain a Gold onto your deck."
        action
        prize
        costs 0

      end
    end
  end
end
