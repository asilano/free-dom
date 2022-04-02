module JournalsHelper
  module Validations
    %i[hand played].each do |location|
      define_method(:"valid_#{location}_card") do |filter: ->(_){ true }, allow_decline: true|
        no_choices = player.send(:"#{location}_cards").none?(&filter)
        return true if params['choice'] == 'none' && (no_choices || allow_decline)
        return false if !no_choices && params['choice'] == 'none'
        return false unless params['choice']&.integer?

        choice = params['choice'].to_i
        choice < player.send(:"#{location}_cards").length && filter[player.send(:"#{location}_cards")[choice]]
      end
    end

    def valid_gain_choice(filter:, allow_decline: true, source: game_state.piles, pile: true)
      source_cards = pile ? source.map(&:cards).map(&:first) : source
      no_choices = source_cards.none?(&filter)
      return true if params["choice"] == "none" && (no_choices || allow_decline)
      return false if !no_choices && params["choice"] == "none"
      return false unless params["choice"]&.integer?

      choice = params["choice"].to_i
      return false if choice >= source.length

      chosen_card = pile ? source[choice].cards.first : source[choice]
      filter[chosen_card]
    end

    def valid_gain_by_cost(max_cost:, allow_decline: true)
      valid_gain_choice(filter: ->(card) { card && card.cost <= max_cost }, allow_decline: allow_decline)
    end
  end
end
