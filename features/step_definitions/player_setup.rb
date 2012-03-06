Given /I am a player in a (?:([2-6])-player )?standard game(?: with (.*))?/ do |player_count, card_list|
  step_text = "Given the following users exist:
      | Name       | Password | Password Confirmation | Email         |
      | Alan       | a        | a                     | a@example.com |
      | Bob        | b        | b                     | b@example.com |
      | Charlie    | c        | c                     | c@example.com |
      | Dave       | d        | d                     | d@example.com |
      | Ethelred   | e        | e                     | e@example.com |
      | Fred       | f        | f                     | f@example.com |"
      
  steps step_text
     
  player_count ||= 3
  @game = Factory.create(:fixed_game, :max_players => player_count.to_i)
  
  if card_list
    reqd_cards = card_list.split(/,\s*/)
    assert_operator reqd_cards.length, :<=, 10
    
    # Kingdom cards start right after Curse
    pos = @game.piles.find_index {|p| p.card_type == 'BasicCards::Curse'} + 1
    reqd_cards.each do |card|
      if !@game.piles(true).map(&:card_type).include?(CARD_TYPES[card].name)
        @game.piles[pos].card_type = CARD_TYPES[card].name
        @game.piles[pos].save!
        pos += 1
      end
    end
  end
  
  players_array = [
    "   | User           | Game         |",
    "   | Name: Alan     | Name: Game 1 |",
    "   | Name: Bob      | Name: Game 1 |",
    "   | Name: Charlie  | Name: Game 1 |",
    "   | Name: Dave     | Name: Game 1 |",
    "   | Name: Ethelred | Name: Game 1 |",
    "   | Name: Fred     | Name: Game 1 |"]
  
  step_text = "Given the following players exist:\n" + players_array[0..player_count.to_i].join("\n")
  
  steps step_text

  names = %w<Alan Bob Charlie Dave Ethelred Fred>[0, player_count.to_i]
  arr = names.map {|name| [name, @game.players.find(:first, :joins => :user, :conditions => ['users.name = ?', name], :readonly => false)]}
  @players = Hash[arr]
  assert_not_nil @players["Alan"]
  
  @game.start_game
  
  # Setup records of the current state of everybody's zones
  @hand_contents = Hash[names.map {|n| [n, @players[n].cards.hand.map(&:readable_name)]}]
  @deck_contents = Hash[names.map {|n| [n, @players[n].cards.deck.map(&:readable_name)]}]
  @play_contents = Hash[names.map {|n| [n, @players[n].cards.in_play.map(&:readable_name)]}]
  @discard_contents = Hash[names.map {|n| [n, @players[n].cards.in_discard.map(&:readable_name)]}]
  @enduring_contents = Hash[names.map {|n| [n, @players[n].cards.enduring.map(&:readable_name)]}]
  @named_cards = {}
end

Given(/^(\w*) ha(?:ve|s) setting (.*) (on|off)/) do |name, setting, value|
  name = "Alan" if name == "I"
  set_sym = {"automoat" => :automoat=,
             "autocrat" => :autocrat_victory=,
             "autobaron" => :autobaron=,
             "autotorture" => :autotorture_curse=,
             "automountebank" => :automountebank=,
             "autotreasury" => :autotreasury=}[setting]
             
  @players[name].settings.send(set_sym, value == "on")
  @players[name].settings.save!
end