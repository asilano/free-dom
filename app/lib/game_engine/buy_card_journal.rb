module GameEngine
  class BuyCardJournal < Journal
    define_question("Buy a card, or pass").prevent_auto
                                          .with_controls do |_game_state|
      [OneCardControl.new(journal_type: BuyCardJournal,
                          question:     self,
                          player:       @player,
                          scope:        :supply,
                          text:         "Buy",
                          filter:       ->(card) { card&.player_can_buy?(player: @player) },
                          null_choice:  { text: "Buy nothing",
                                          value: "none" },
                          css_class:    "buy-card")]
    end

    validation do
      return true if params["choice"] == "none"
      return false unless params["choice"]&.integer?

      choice = params["choice"].to_i
      return false unless choice < game_state.piles.length + game_state.card_shapeds.length

      if choice < game_state.piles.length
        game_state.piles[choice].cards.first&.player_can_buy?(player: player)
      else
        game_state.card_shapeds[choice - game_state.piles.length].player_can_buy?(player: player)
      end
    end

    process do |game_state|
      if params["choice"] == "none"
        player.buys = 0
        @histories << History.new("#{player.name} bought nothing.",
                                  player: player,
                                  css_classes: %w[buy-card])
        return
      end

      player.buys -= 1

      choice = params["choice"].to_i
      if choice < game_state.piles.length
        buy_card(choice, player)
      else
        buy_card_shaped(choice - game_state.piles.length, player)
      end
    end

    def buy_card(pile_index, player)
      pile = game_state.piles[pile_index]
      card = pile.cards.first
      player.cash -= card.cost

      @histories << History.new("#{player.name} bought #{card.readable_name} for #{card.cost}.",
                                player: player,
                                css_classes: %w[buy-card])

      Triggers::CardBought.trigger(card, player)

      card.be_gained_by(player, from: pile.cards)
    end

    def buy_card_shaped(card_shaped_index, player)
      card_shaped = game_state.card_shapeds[card_shaped_index]
      player.cash -= card_shaped.cost

      @histories << History.new("#{player.name} bought the #{card_shaped.class.types.join("-")} #{card_shaped.readable_name} for #{card_shaped.cost}.",
                                player: player,
                                css_classes: %w[buy-card_shaped])
      card_shaped.be_bought_by(player)
    end
  end
end
