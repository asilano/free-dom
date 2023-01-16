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
      supply = basic_piles.map(&:constantize) + params["card_list"]
                                                .take(10)
                                                .map(&:constantize)
                                                .sort_by(&:sort_key)
      supply.each do |card_class|
        game_state.piles << GameEngine::Pile.new(card_class)
      end

      params["card_list"][10..].map(&:constantize).sort_by(&:sort_key).each do |card_shaped|
        game_state.card_shapeds << card_shaped.new(game_state)
      end

      @histories << History.new("#{params["card_list"].map(&:demodulize).map(&:titleize).join(', ')} chosen for the kingdom.")
    end

    private

    def valid_kingdom_choices
      kingdom_choice_errors.each { |err| errors.add(:base, err) }
    end

    def kingdom_choice_errors
      card_list = params["card_list"]
      return ["does not appear to be a list of cards"] unless card_list.is_a? Array
      errs = []
      errs << "has only #{card_list.uniq.length} members" unless card_list.uniq.length >= 10
      errs << "is not unique" unless card_list.uniq.length == card_list.length
      errs.concat card_list_errors(card_list)
      errs
    end

    def card_list_errors(card_list)
      card_list.map.with_index do |card, ix|
        card_class = card.constantize
        if ix < 10
          "- #{card_class.readable_name} is not a Card subclass" unless card_class.ancestors.include? GameEngine::Card
        else
          next "- #{card_class.readable_name} is not in the CardShapedThing namespace" unless card_class.module_parents.include? GameEngine::CardShapedThings
          "- #{card_class.readable_name} is not a randomised CardShapedThing" unless card_class.randomiser?
        end
      rescue NameError
        "- #{card} is not a type"
      end.compact
    end
  end
end
