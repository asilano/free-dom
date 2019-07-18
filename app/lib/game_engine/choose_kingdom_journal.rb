module GameEngine
  class ChooseKingdomJournal < Journal
    define_question 'Choose a Kingdom'

    validate :valid_kingdom_choices

    validation do
      journal.kingdom_choice_errors.empty?
    end

    process do |game_state|
      prevent_undo

      # Add the basic cards
      basic_piles = %w[Estate Duchy Province Copper Silver Gold Curse].map do |basic_type|
        "GameEngine::BasicCards::#{basic_type}"
      end
      supply = basic_piles.map(&:constantize) + params['card_list'].map(&:constantize).sort_by(&:raw_cost)
      supply.each do |card_class|
        game_state.piles << GameEngine::Pile.new(card_class)
      end

      @histories << History.new("#{params['card_list'].map(&:demodulize).map(&:titleize).join(', ')} chosen for the kingdom.")
    end

    def kingdom_choice_errors
      card_list = params['card_list']
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
