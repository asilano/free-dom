module GameEngine
  class BuyCardJournal < Journal
    define_question('Buy a card, or pass').prevent_auto
                                          .with_controls do |_game_state|
      [OneCardControl.new(journal_type: BuyCardJournal,
                          question: self,
                          player: @player,
                          scope: :supply,
                          text: 'Buy',
                          filter: ->(card) { card&.player_can_buy?(player: @player) },
                          null_choice: { text: 'Buy nothing',
                                         value: 'none' },
                          css_class: 'buy-card')]
    end

    validation do
      return true if params['choice'] == 'none'
      return false unless params['choice']&.integer?

      choice = params['choice'].to_i
      choice < game_state.piles.length &&
        game_state.piles[choice].cards.first&.player_can_buy?(player: player)
    end

    process do |game_state|
      if params['choice'] == 'none'
        player.buys = 0
        @histories << History.new("#{player.name} bought nothing.",
                                  player: player,
                                  css_classes: %w[buy-card])
        return
      end

      player.buys -= 1
      pile = game_state.piles[params['choice'].to_i]
      card = pile.cards.first
      player.cash -= card.cost

      @histories << History.new("#{player.name} bought #{card.readable_name} for #{card.cost}.",
                                player: player,
                                css_classes: %w[buy-card])
      card.be_gained_by(player, from: pile.cards)
    end
  end
end