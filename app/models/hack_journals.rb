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
end