module GameEngine
  module Helpers
    def self.gain_card_from_supply(game_state, player:, card_class:, to: :discard, tap_card: nil)
      pile = game_state.find_pile_by_top_card { |c| c.is_a? card_class }
      card = pile&.cards&.first
      game = game_state.game

      if card
        tap_card.call(card) if tap_card
        game.current_journal.histories << History.new("#{player.name} gained a #{card_class.readable_name}#{" to their #{to}" unless to == :discard}.",
                                                      player:      player,
                                                      css_classes: %w[gain-card])
        card.be_gained_by(player, from: pile.cards, to: to)
      else
        game.current_journal.histories << History.new("#{player.name} couldn't gain a #{card_class.readable_name}.",
                                                      player:      player,
                                                      css_classes: %w[gain-card])

      end
    end
  end
end
