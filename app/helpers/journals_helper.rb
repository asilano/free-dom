module JournalsHelper
  module Validations
    def valid_hand_card(filter: ->(_){ true }, allow_decline: true)
      no_choices = player.hand_cards.none?(&filter)
      return true if params['choice'] == 'none' && (no_choices || allow_decline)
      return false if !no_choices && params['choice'] == 'none'
      return false unless params['choice']&.integer?

      choice = params['choice'].to_i
      choice < player.hand_cards.length && filter[player.hand_cards[choice]]
    end

    def valid_gain_choice(filter:, allow_decline: true)
      no_choices = game_state.piles.map(&:cards).map(&:first).none?(&filter)
      return true if params['choice'] == 'none' && (no_choices || allow_decline)
      return false if !no_choices && params['choice'] == 'none'
      return false unless params['choice']&.integer?

      choice = params['choice'].to_i
      choice < game_state.piles.length && filter[game_state.piles[choice].cards.first]
    end

    def valid_gain_by_cost(max_cost:, allow_decline: true)
      valid_gain_choice(filter: ->(card) { card && card.cost <= max_cost }, allow_decline: allow_decline)
    end
  end
end
