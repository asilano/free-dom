module GameEngine
  module Renaissance
    class Spices < Card
      text "$2",
           "+1 Buy",
           :hr,
           "When you gain this, +2 Coffers."
      treasure special: true, cash: 2
      costs 5

      def play_as_treasure(played_by:)
        super

        played_by.grant_buys(1)
        played_by.coffers += 2
      end
    end
  end
end
