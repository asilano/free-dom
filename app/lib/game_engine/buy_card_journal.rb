module GameEngine
  class BuyCardJournal < Journal
    define_question('Buy a card, or pass').with_controls do |_game_state|
      [OneCardControl.new(player: @player,
                          scope: :piles,
                          text: 'Buy',
                          filter: ->(card) { card&.player_can_buy?(player: @player) },
                          null_choice: { 'Buy nothing' => 'none' },
                          css_class: 'buy-card')]
    end

    validation do
      return true if journal.params['choice'] == 'none'
      return false unless journal.params['choice'].integer?

      choice = journal.params['choice'].to_i
      choice < journal.game_state.piles.length &&
        journal.game_state.piles[choice].cards.first&.player_can_buy?(player: journal.player)
    end

    process do |game_state|
      if params['choice'] == 'none'
        player.buys = 0
        @histories << History.new("#{player.name} bought nothing.",
                                  player: player)
        return
      end

      player.buys -= 1
      pile = game_state.piles[params['choice'].to_i]
      card = pile.cards.first

      @histories << History.new("#{player.name} bought #{card.readable_name} for #{card.cost}.",
                                player: player)
      card.be_gained_by(player, from: pile.cards)
    end
  end
end