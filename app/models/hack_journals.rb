module HackJournals
  class HackPlayerCardsJournal < Journal
    causes :hack_player_cards
    validates_hash_keys :parameters do
      validates :player_id, presence: true, player: true
      validates :location, inclusion: { in: %w[hand deck play discard enduring] }
      validates :mod_type, inclusion: { in: %w[add remove set] }
      validates_each_in_array :card_types do
        validates :value, card_type: true
      end
    end

    text do
      name = Player.find(parameters[:player_id]).name
      "HACK: #{name}'s #{parameters[:location]} - #{parameters[:mod_type]} #{parameters[:card_types].map{ |p| p.sub(/.*::/, '').titleize }.join(', ')}"
    end

    def hack_journal?
      true
    end
  end

  class HackGainJournal < Journal
    causes :hack_gain
    validates_hash_keys :parameters do
      validates :player_id, presence: true, player: true
      validates :location, inclusion: { in: %w[hand deck play discard enduring] }
      validates :position, numericality: true
      validates :card_id, card: true
    end

    text do
      name = Player.find(parameters[:player_id]).name
      card = game.find_card(parameters[:card_id])
      "HACK: #{name} gained #{card} to #{parameters[:location]} position #{parameters[:position]}"
    end

    def hack_journal?
      true
    end
  end

  class HackStartTurnJournal < Journal
    causes :hack_start_turn
    validates_hash_keys :parameters do
      validates :player_id, presence: true, player: true
    end

    text do
      name = Player.find(parameters[:player_id]).name
      "HACK: Started #{name}'s turn"
    end

    def hack_journal?
      true
    end
  end
end