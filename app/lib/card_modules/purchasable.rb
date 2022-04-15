module CardModules
  module Purchasable
    def player_can_buy?(player:)
      cost <= player.cash
    end
  end
end
