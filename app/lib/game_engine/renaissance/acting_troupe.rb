module GameEngine
  module Renaissance
    class ActingTroupe < Card
      text "+4 Villagers. Trash this"
      action
      costs 3

      def play_as_action(played_by:)
        super

        played_by.villagers += 4
        trash(from: played_by.cards)
      end
    end
  end
end
