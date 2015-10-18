# Monument (Action - $4) - +2 Cash, +1 VP

class Prosperity::Monument < Card
  action
  costs 4
  card_text "Action (cost: 4) - +2 Cash, +1 VP."

  def play(parent_act)
    super

    player.add_cash(2)
    player.add_vps(1)

    game.histories.create!(:event => "#{player.name} scored 1 VP from #{self}.",
                          :css_class => "player#{player.seat} score")

    return "OK"
  end
end