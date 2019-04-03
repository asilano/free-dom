module GameEngine
  class ChooseKingdomJournal < Journal
    define_question 'Choose a Kingdom'

    validate :valid_kingdom_choices

    def cards
      return [] unless params
      params['card_list']
    end

    def cards=(arr)
      params_will_change!
      self.params ||= {}
      self.params['card_list'] = arr
    end

    validation do
      journal.kingdom_choice_errors.empty?
    end

    def process(game_state)
      super
      params['card_list'].each do |card|
        card_class = card.constantize
        game_state.piles << GameEngine::Pile.new(card_class)
        game_state.logs << "Added #{card_class.readable_name} to the kingdom"
      end
    end

    def kingdom_choice_errors
      card_list = cards
      return ['cards_list not an Array'] unless card_list.is_a? Array
      return ["cards_list has #{card_list.uniq.length} members"] unless card_list.uniq.length == 10
      card_list.map do |card|
        begin
          card_class = card.constantize
          "#{card} is not a Card subclass" unless card_class.ancestors.include? GameEngine::Card
        rescue NameError
          "#{card} is not a type"
        end
      end.compact
    end

    private

    def valid_kingdom_choices
      kingdom_choice_errors.each { |err| errors.add(:params, err) }
    end
  end
end
