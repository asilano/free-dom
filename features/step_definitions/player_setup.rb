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
    
    pos = 1
    reqd_cards.each do |card|
      if !@game.piles(true).map(&:card_type).include?(CARD_TYPES[card].name)
        @game.piles[pos].card_type = CARD_TYPES[card].name
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
      
  @me = @game.players.find(:first, :joins => :user, :conditions => ['users.name = ?', 'Alan'], :readonly => false)
  assert_not_nil @me
  
  @game.start_game
end