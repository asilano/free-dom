class BasicCards::Copper < Card
  costs 0
  treasure :cash => 1
  pile_size { |num_players| 60 - 7 * num_players }
  card_text "Treasure (cost: 0) - 1 cash"

  def cash
    # Override the instance method cash() in order to take account of
    # Coppersmiths
    coppersmiths = game.facts.include?(:coppersmiths) ? game.facts[:coppersmiths] : 0
    return self.class.cash + coppersmiths
  end
end

