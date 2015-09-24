Given /I am a player in a (?:([2-6])-player )?standard game(?: with (.*))?/ do |player_count, card_list|
  unless @test_players
    [
      {name: 'Alan', password: 'a', password_confirmation: 'a', email: 'a@example.com'},
      {name: 'Bob', password: 'b', password_confirmation: 'b', email: 'b@example.com'},
      {name: 'Charlie', password: 'c', password_confirmation: 'c', email: 'c@example.com'},
      {name: 'Dave', password: 'd', password_confirmation: 'd', email: 'd@example.com'},
      {name: 'Ethelred', password: 'e', password_confirmation: 'e', email: 'e@example.com'},
      {name: 'Fred', password: 'f', password_confirmation: 'f', email: 'f@example.com'}
    ].each { |u| FactoryGirl.create(:user, u) }
  end

  @test_game.andand.destroy
  player_count ||= 3

  @test_game = FactoryGirl.create(:fixed_game, :max_players => player_count.to_i)

  if card_list
    reqd_cards = card_list.split(/,\s*/)
    assert_operator reqd_cards.length, :<=, 10

    # Kingdom cards start right after Curse
    pos = @test_game.piles.find_index {|p| p.card_type == 'BasicCards::Curse'} + 1
    cards_needed = reqd_cards + @test_game.piles[pos..-1].map(&:card_type).map(&:readable_name)
    cards_needed.uniq!

    @test_game.piles[pos..-1].each_with_index do |pile, ix|
      pile.update_attribute("card_type", ix)
    end

    cards_needed.take(10).each do |card|
      @test_game.piles[pos].update_attribute("card_type", CARD_TYPES[card].name)
      pos += 1
    end
  end

  names = %w<Alan Bob Charlie Dave Ethelred Fred>[0, player_count.to_i]
  names.each do |n|
    FactoryGirl.create(:player, user: User.where { name == n }.first, game: @test_game)
  end

  arr = names.map { |name| [name, @test_game.players.joins { user }.where { users.name == name }.readonly()] }
  @test_players = Hash[arr]
  assert_not_nil @test_players["Alan"]

  @test_game.reload.start_game

  Game.current = @test_game

  # Setup records of the current state of everybody's zones
  @hand_contents = Hash[names.map {|n| [n, @test_players[n].cards.hand.map(&:readable_name)]}]
  @deck_contents = Hash[names.map {|n| [n, @test_players[n].cards.deck.map(&:readable_name)]}]
  @play_contents = Hash[names.map {|n| [n, @test_players[n].cards.in_play.map(&:readable_name)]}]
  @discard_contents = Hash[names.map {|n| [n, @test_players[n].cards.in_discard.map(&:readable_name)]}]
  @enduring_contents = Hash[names.map {|n| [n, @test_players[n].cards.enduring.map(&:readable_name)]}]
  @named_cards = {}
end

Given(/^(\w*) ha(?:ve|s) setting (.*) (on|off)/) do |name, setting, value|
  name = "Alan" if name == "I"
  set_sym = {"automoat" => :automoat=,
             "autocrat" => :autocrat_victory=,
             "autobaron" => :autobaron=,
             "autotorture" => :autotorture_curse=,
             "automountebank" => :automountebank=,
             "autotreasury" => :autotreasury=,
             "autooracle" => :autooracle=,
             "autoscheme" => :autoscheme=,
             "autobrigand" => :autobrigand=}[setting]

  @test_players[name].settings.send(set_sym, value == "on")
  @test_players[name].settings.save!
end

Given(/^(\w*) ha(?:ve|s) setting (.*) set to (.*)/) do |name, setting, value|
  name = "Alan" if name == "I"
  set_sym = {"autoduchess" => :autoduchess=,
             "autofoolsgold" => :autofoolsgold=,
             "autotunnel" => :autotunnel=,
             "autoigg" => :autoigg=}[setting]
  if Settings.constants.include?(value.to_sym)
    value = Settings.const_get(value)
  end

  @test_players[name].settings.send(set_sym, value)
  @test_players[name].settings.save!
end

Given(/^(.*?)(?:'s)? state (\w*) is (.*)$/) do |name, prop, value|
  name = "Alan" if name == "my"

  set_sym = {
    "outpost_queued"   => :outpost_queued=  ,
    "outpost_prevent"  => :outpost_prevent= ,
    "pirate_coins"     => :pirate_coins=    ,
    "gained_last_turn" => :gained_last_turn=,
    "bought_victory"   => :bought_victory=  ,
    "played_treasure"  => :played_treasure= }[prop]

  @test_players[name].state.send(set_sym, value)
  @test_players[name].state.save!
end

Given(/^(\w*) ha(?:ve|s) (\d+) cash/) do |name, amount|
  name = "Alan" if name == "I"

  @test_players[name].cash = amount
  @test_players[name].save!
end
