module AgnosticGameController
  def ag_create(game_params)
    @game = Game.new(game_params)
       
    if @game.random_select.to_i == 1
      # User chose a random selection. Make sure their random choices are valid
      if !@game.valid?        
        return :invalid
      end
        
      @game.expand_random_choices
      
      @game.random_select = "tweak"
      return :tweak
    else    
      # Create the player
      @player = @user.players.build
      
      # Now go about doing the database operations in a transaction. 
      begin
        Game.transaction do
          @game.save!          
          
          # Use the Game's helper function to add the player to the game. This will
          # raise an exception if it fails.
          @game.add_player(@player)
          @player.save!      
                
          return :created
        end
      rescue ActiveRecord::RecordInvalid
        @game.valid?

        return :invalid
      end
    end
  end
  
  def ag_join
    if @game.users.include? @user
      return :already
    end
    
    player = nil
    if @game.state == 'waiting' and 
       @game.players.length < @game.max_players
      # Game has not yet started, and still has available seats.            
      
      # Create a player. Do this in a transaction, as add_player will raise if 
      # the game has filled in the meantime.
      begin
        Game.transaction do
          player = @user.players.create
          @game.add_player(player)
        end
      rescue
        if player.valid?
          @game.errors.add_to_base("Failed to join game - game full")
        end
      end
    end
    
    if player
      return :joined
    else
      return :failed
    end
  end
end