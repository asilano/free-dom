# WorkersVillage (Action - $4) - Draw 1 card, +2 Actions, +1 Buy

class Prosperity::WorkersVillage < Card
  action
  costs 4
  card_text "Action (cost: 4) - Draw 1 card, +2 Actions, +1 Buy."

  def self.readable_name
    "Workers' Village"
  end

  def play(parent_act)
    super

    player.draw_cards(1)
    player.add_actions(2, parent_act)
    player.add_buys(1, parent_act)

    "OK"
  end
end