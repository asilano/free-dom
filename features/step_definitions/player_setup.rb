Given /I am a player in a standard game(?: with (.*))?/ do |card_list|
  steps %Q<Given the following users exist:
      | Name | Password | Password Confirmation | Email         |
      | Alan | a        | a                     | a@example.com |
      | Bob  | b        | b                     | b@example.com |
      | Chas | c        | c                     | c@example.com |>
  @game = Factory.create(:fixed_game)
  
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
  
  steps %Q<Given the following players exist:
      | User       | Game         |
      | Name: Alan | Name: Game 1 |
      | Name: Bob  | Name: Game 1 |
      | Name: Chas | Name: Game 1 |>
      
  @me = @game.players.find(:first, :joins => :user, :conditions => ['users.name = ?', 'Alan'], :readonly => false)
  assert_not_nil @me
  
  @game.start_game
end