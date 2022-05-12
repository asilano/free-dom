module GameEngine
  class ChooseKingdomJournal < Journal
    define_question "Choose a Kingdom"

    validate :valid_kingdom_choices

    validation do
      kingdom_choice_errors.empty?
    end

    process do |game_state|
      prevent_undo

      # Add the basic cards
      basic_piles = %w[Estate Duchy Province Copper Silver Gold Curse].map do |basic_type|
        "GameEngine::BasicCards::#{basic_type}"
      end
      supply = basic_piles.map(&:constantize) + params["card_list"].take(10).map(&:constantize).sort_by(&:raw_cost)
      supply.each do |card_class|
        game_state.piles << GameEngine::Pile.new(card_class)
      end

      params["card_list"][10..].map(&:constantize).sort_by(&:raw_cost).each do |card_shaped|
        game_state.card_shapeds << card_shaped.new(game_state)
      end

      @histories << History.new("#{params["card_list"].map(&:demodulize).map(&:titleize).join(', ')} chosen for the kingdom.")
    end

    private

    def valid_kingdom_choices
      kingdom_choice_errors.each { |err| errors.add(:params, err) }
    end

    def kingdom_choice_errors
      card_list = params["card_list"]
      return ["cards_list not an Array"] unless card_list.is_a? Array
      return ["cards_list has #{card_list.uniq.length} members"] unless card_list.uniq.length >= 10
      card_list_errors(card_list)
    end

    def card_list_errors(card_list)
      card_list.map.with_index do |card, ix|
        card_class = card.constantize
        if ix < 10
          "#{card} is not a Card subclass" unless card_class.ancestors.include? GameEngine::Card
        else
          next "#{card} is not in the CardShapedThing namespace" unless card_class.module_parents.include? GameEngine::CardShapedThings
          "#{card} is not a randomised CardShapedThing" unless card_class.randomiser?
        end
      rescue NameError
        "#{card} is not a type"
      end.compact
    end
  end
end
