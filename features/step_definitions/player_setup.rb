Given(/I am a player in a (?:([2-6])-player )?(standard|Platinum-Colony) game(?: with (.*))?/) do |player_count, type, card_list|
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

  @test_game = FactoryGirl.build(:fixed_game, :max_players => player_count.to_i)

  if card_list
    reqd_cards = card_list.split(/,\s*/)
    assert_operator reqd_cards.length, :<=, 10

    reqd_cards.each.with_index do |type, ix|
      if !(1..10).any? { |jx| @test_game.send("pile_#{jx}") == CARD_TYPES[type].name }
        @test_game.send("pile_#{ix+1}=", CARD_TYPES[type].name)
      end
    end
  end

  if type == 'Platinum-Colony'
    @test_game.plat_colony = 'yes'
  end

  @test_game.save!

  names = %w<Alan Bob Charlie Dave Ethelred Fred>[0, player_count.to_i]
  names.each do |n|
    FactoryGirl.create(:player, user: User.where { name == n }.first, game: @test_game)
  end

  arr = names.map { |name| [name, @test_game.players.joins { user }.where { users.name == name }.readonly(false).first] }
  @test_players = Hash[arr]
  assert_not_nil @test_players["Alan"]

  @test_game.add_journal(type: 'Game::Journals::StartGameJournal', player: @test_players["Alan"])
  @test_game.reload.process_journals

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
