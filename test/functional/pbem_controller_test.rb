require File.dirname(__FILE__) + '/../test_helper'
require 'mail'

class PbemControllerTest < ActionController::TestCase

  SECRET = ENV['CLOUDMAILIN_SECRET'] || '46075664a79b141cfbac'

  def sign_message(params)
    Digest::MD5.hexdigest(flatten_params(params).sort.map{|k,v| v}.join + SECRET)
  end

  context "with user defined" do
    setup do
      @user = user = Factory(:user, :pbem => true)
      ENV['CLOUDMAILIN_FORWARD_ADDRESS'] = "fwd@cloudmailin.com"      
      
      @base_mail = Mail.new do
        to    ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
        from  user.email        
      end
    end
    
    should "reject email with bad user" do
      @base_mail.body = "Username: #{@user.name.succ}"
      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
                :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements @base_mail.from, email.to
      assert_match(/Supplied username invalid or mismatched with To: address/, email.body)
    end
    
    should "reject email with user / reply-to mismatch" do
      @base_mail.body = "Username: #{@user.name}"
      @base_mail.to = @base_mail.to.to_s.sub(/@/, 'FOO@')
      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
                :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}FOO"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements @base_mail.from, email.to
      assert_match(/Supplied username invalid or mismatched with To: address/, email.body)
    end
    
    should "handle new game (distribution) email" do
      @base_mail.body = <<EOF
Username: #{@user.name}      
Action: Create Game
Game Name: Test Game  
Max Players: 4    
Random: true
Distribution: true
BaseGame: 7
Prosperity: 3
EOF

      qshuffle([(0...BaseGame.kingdom_cards.length).to_a, /expand_random_choices/],
                ['?', /expand_random_choices/],
                ['?', /expand_random_choices/],
                [(0...Prosperity.kingdom_cards.length).to_a, /expand_random_choices/])
                
      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
                :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Confirm / Modify New Game Details", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Action: Create Game/, email.body)
      assert_match(/Username: #{@user.name}/, email.body)
      assert_match(/Name: Test Game/, email.body)
      assert_match(/Max Players: 4/, email.body)
      
      BaseGame.kingdom_cards[0,7].each do |card|
        assert_match(/Kingdom Card \d+: BaseGame - #{card.readable_name} \[#{Regexp.quote card.text}\]/, email.body)
      end
      
      Prosperity.kingdom_cards[0,3].each do |card|
        assert_match(/Kingdom Card \d+: Prosperity - #{card.readable_name} \[#{Regexp.quote card.text}\]/, email.body)
      end
      
      assert_match(/Include Platinum and Colony: rules/, email.body)
    end
    
    should "handle new game (presence) email" do
      @base_mail.body = <<EOF
Username: #{@user.name}      
Action: Create Game
Game Name: Test Game  
Max Players: 4    
Random: true
Distribution: false
Seaside: true
Intrigue: true
EOF

      queue = [0,1,2,3,4] + [0,1,2,3,4].map {|n| Intrigue.kingdom_cards.length + n}
      queue += (5...Intrigue.kingdom_cards.length).to_a
      queue += (5...Seaside.kingdom_cards.length).to_a.map {|n| Intrigue.kingdom_cards.length + n}
      qshuffle([queue, /expand_random_choices/])
                
      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
                :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Confirm / Modify New Game Details", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Action: Create Game/, email.body)
      assert_match(/Username: #{@user.name}/, email.body)
      assert_match(/Name: Test Game/, email.body)
      assert_match(/Max Players: 4/, email.body)
      
      Seaside.kingdom_cards[0,5].each do |card|
        assert_match(/Kingdom Card \d+: Seaside - #{card.readable_name} \[#{Regexp.quote card.text}\]/, email.body)
      end
      
      Intrigue.kingdom_cards[0,5].each do |card|
        assert_match(/Kingdom Card \d+: Intrigue - #{card.readable_name} \[#{Regexp.quote card.text}\]/, email.body)
      end
      
      assert_match(/Include Platinum and Colony: rules/, email.body)
    end
    
    should "reject new game email with invalid options" do
      @base_mail.body = <<EOF
Username: #{@user.name}      
Action: Create Game
Game Name:   
Max Players: 4    
Random: true
Distribution: true
BaseGame: 5
Prosperity: 3
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
                :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Errors in New Game request", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Name can't be blank/, email.body)
      assert_match(/must sum to 10/, email.body)
    end
    
    should "handle game create email" do
      game_name = "Test Game"
      @base_mail.body = <<EOF
Username: #{@user.name}
Action: Create Game
Game Name: #{game_name}
Max Players: 4

Kingdom Card 1: Intrigue - Courtyard
Kingdom Card 2: Intrigue::Pawn
Kingdom Card 3: Intrigue - Secret Chamber
Kingdom Card 4: Intrigue - Great Hall [Action/Victory (cost: 3) - Draw 1 card, +1 Action. / 1 point.]
Kingdom Card 5: Intrigue - Masquerade
Kingdom Card 6: Seaside - Embargo
Kingdom Card 7: BaseGame  Adventurer
Kingdom Card 8: Seaside - Lighthouse
Kingdom Card 9: Seaside - Native Village [Action (cost: 2) - +2 Actions. Choose one: Set aside the top card of your deck face down on your Native Village mat; or put all the cards from your mat into your hand.]
Kingdom Card 10: Seaside - Pearl Diver [Action (cost: 2) - Draw 1 card, +1 Action. Look at the bottom card of your deck. You may put it on top.]

Include Platinum and Colony: rules
EOF
    
      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
                :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Game '#{game_name}' Created", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/created successfully/, email.body)
      assert_match(/Game number (\d+): #{game_name} \(waiting to start\)/, email.body)
      assert_match(/Events since last update:\n - Game #{game_name} created.[ \t]*\n - #{@user.name} joined the game./, email.body)
      assert_match(/Chat since last update:\n - Game said: Welcome to '#{game_name}'!/, email.body)
      assert_match(/#{@user.name}:\s*\n-*\n(\s+)Deck: 0 cards\s*\n\1Hand: None\s*\n\1In Play: None\s*\n\1Discard: None/, email.body)
      assert_match(/Piles:/, email.body)
      ([BasicCards::Estate, BasicCards::Duchy, BasicCards::Province] +
        [BasicCards::Copper, BasicCards::Silver, BasicCards::Gold, BasicCards::Curse] +
        [Intrigue::Courtyard, Intrigue::Pawn, Intrigue::SecretChamber, 
         Intrigue::GreatHall, Intrigue::Masquerade, Seaside::Embargo,
         BaseGame::Adventurer, Seaside::Lighthouse, Seaside::NativeVillage,
         Seaside::PearlDiver].sort_by {|c| [c.cost, c.name]}).each_with_index do |pile, ix|
        assert_match(/#{ix}\.\s+#{pile.readable_name}\s+#{pile.cost}\s+0\s+\((of  8|of 10|of  0|inf\. )\)/, email.body)
      end
    end
             
    should "handle join game email" do
      @game = Factory(:fixed_game)
      @user_bob = Factory(:user, :name => "Bob", :password => "b")
      @user_chas = Factory(:user, :name => "Chas", :password => "c")
      
      @user.pbem = true
      @user.save!
      @ply_bob = Factory(:player, :user => @user_bob, :game => @game)
      @ply_chas = Factory(:player, :user => @user_chas, :game => @game)
      
      @base_mail.body = <<EOF
Username: #{@user.name}
Action: Join Game
Game Number: #{@game.id}
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Joined Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/You have successfully joined game '#{@game.name}'./, email.body)
    end
    
    context "with pbem user game created" do
      setup do
        @game = Factory(:fixed_game)
        @ply_alan = Factory(:player, :user => @user, :game => @game)
      end
      
      should "be emailed about new joiners" do
        sleep(1)
        user_bob = Factory(:user, :name => "Bob", :password => "b")
        ply_bob = Factory(:player, :user => user_bob, :game => @game)
        
        get :nop
        
        email = ActionMailer::Base.deliveries.shift
        assert_same_elements [@user.email], email.to
        assert_equal "free-dom: #{ply_bob.name} joined '#{@game.name}'", email.subject
        assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
        assert_match(/#{ply_bob.name} joined/, email.body)       
        flunk "Player Joined trigger should be an integration test"
      end
      
      should "handle game start email" do
        user_bob = Factory(:user, :name => "Bob", :password => "b")
        ply_bob = Factory(:player, :user => user_bob, :game => @game)
        Player.to_email = []
        
        @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Action: Start Game
EOF

        qshuffle([[0,1], /start_game/, /player\.rb/])
        params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
                :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
        post :handle, params.merge(:signature => sign_message(params))
        
        assert_response(:success)
        
        email = ActionMailer::Base.deliveries.shift
        assert_same_elements [@user.email], email.to
        assert_equal "free-dom: Game '#{@game.name}' Started", email.subject
        assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
        assert_match(/The game '#{@game.name}' has been started./, email.body)
      end
    end
  end
  
  context "in running game of 3 players" do
    setup do
      qshuffle([[9,8,0,1,2,3,4,5,6,7], /player\.rb.*start_game/])
      stub_game
      @user_alan.update_attributes(:pbem => true)
      @user = user = @user_alan   
      @player = @ply_alan
      
      ENV['CLOUDMAILIN_FORWARD_ADDRESS'] = "fwd@cloudmailin.com"      
      
      @base_mail = Mail.new do
        to    ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
        from  user.email        
      end
    end
    
    should "handle passing play_action then buying" do
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      play_act = @player.active_actions(true)[0]
      assert_equal 'buy', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Pile 9
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} bought #{@game.piles[9].card_type.readable_name}/, email.body)
    end
    
    should "reject attempt to play non-action" do
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Problem with your request", email.subject
      assert_match(/is not an action/, email.body)
    end
    
    should "reject wrong param type" do
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Pile 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Problem with your request", email.subject
      assert_match(/Invalid parameters/, email.body)
    end
    
    should "reject malformed params" do
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Flibble
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Problem with your request", email.subject
      assert_match(/Didn't understand your choice/, email.body)
    end
    
    should "handle playing trivial action" do
      c = @player.cards.hand[0]
      c.type = "BaseGame::Smithy"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Smithy\.[ \t]*\n - #{@user.name} drew Copper, Copper, Copper/, email.body)
    end
    
    should "handle playing action with button choice" do
      c = @player.cards.hand[0]
      c.type = "Seaside::Salvager"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Salvager\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Seaside::Salvager/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Card 2
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} trashed a /, email.body)
      assert_match(/Buy \(PA/, email.body)
    end
    
    should "handle playing action with repeated hand choice" do
      c = @player.cards.hand[0]
      c.type = "BaseGame::Chapel"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Chapel\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_BaseGame::Chapel/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Card 2
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} trashed a /, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_BaseGame::Chapel/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} trashed a /, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_BaseGame::Chapel/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} stopped trashing\./, email.body)
    end
    
    should "handle playing action with pile choice" do
      c = @player.cards.hand[0]
      c.type = "BaseGame::Workshop"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Workshop\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_BaseGame::Workshop/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Pile 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} took Estate from the Workshop\./, email.body)
    end
    
    should "handle playing action with Player-level buttons" do
      c = @player.cards.hand[0]
      c.type = "BaseGame::Chancellor"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Chancellor \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Chancellor\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_BaseGame::Chancellor/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Choose keep
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} chose not to discard their deck\./, email.body)
    end
    
    should "handle playing action with checkboxes" do
      c = @player.cards.hand[0]
      c.type = "BaseGame::Cellar"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Cellar \(PA.*: 'discard' then a space-separated set from 0, 1, 2, 3/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Cellar\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_BaseGame::Cellar/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: discard 0 1 3
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} discarded Estate, Copper, Copper/, email.body)
    end
    
    should "handle playing action with Player checkboxes" do
      c = @player.cards.hand[0]
      c.type = "Intrigue::Pawn"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Pawn \(PA.* then a space-separated set from 0 for Draw 1, 1 for \+1 Action,/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Pawn\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Intrigue::Pawn/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Choose 2 3
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} chose Buy and Cash with Pawn/, email.body)
    end
    
    should "handle playing action with 2D Radio control on self only" do
      c = @player.cards.hand[0]
      c.type = "BaseGame::Spy"
      c.save!
      
      c = @ply_bob.cards.hand[0]
      c.type = "BaseGame::Moat"
      c.save!
      c = @ply_chas.cards.hand[0]
      c.type = "BaseGame::Moat"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Spy actions for #{@user.name} \(PA.*:.* card belonging to #{@user.name}.*Option is one of/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Spy\./, email.body)
      assert_match(/ - #{@user_bob.name} reacted with a Moat/, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_BaseGame::Spy/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Choose 0.1
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} chose to put #{@user.name}'s Copper back/, email.body)
    end
    
    should "handle playing action with 2D Radio control on many at once" do
      c = @player.cards.hand[0]
      c.type = "BaseGame::Thief"
      c.save!
      
      c = @ply_bob.cards.deck[0]
      c.type = "BasicCards::Copper"
      c.save!
      c = @ply_bob.cards.deck[1]
      c.type = "BasicCards::Gold"
      c.save!
      c = @ply_chas.cards.deck[0]
      c.type = "BasicCards::Copper"
      c.save!
      c = @ply_chas.cards.deck[1]
      c.type = "BasicCards::Estate"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Thief actions for #{@user_bob.name} \(PA.*:.* card belonging to #{@user_bob.name}.*Card is one of 0, 1 and Option is one of/, email.body)
      assert_match(/Thief actions for #{@user_chas.name} \(PA.*:.* card belonging to #{@user_chas.name}.*Card is one of 0 and Option is one of/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Thief\./, email.body)
      
      sleep(1)
      assert_equal 2, @player.active_actions(true).length
      resolve_acts = @player.active_actions(true)
      assert_match(/resolve_BaseGame::Thief/, resolve_acts[0].expected_action)
      assert_match(/resolve_BaseGame::Thief/, resolve_acts[1].expected_action)
      bob_act = resolve_acts.detect {|act| act.expected_action =~ /target=#{@ply_bob.id}/}
      chas_act = resolve_acts.detect {|act| act.expected_action =~ /target=#{@ply_chas.id}/}
      assert_not_nil bob_act
      assert_not_nil chas_act
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{bob_act.id}: Choose 1.1
Resolve PA #{chas_act.id}: Choose 0.0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} chose to steal #{@user_bob.name}'s Gold/, email.body)
      assert_match(/ - #{@user.name} chose to trash #{@user_chas.name}'s Copper/, email.body)
    end
    
    should "handle dropdown" do
      c = @player.cards.hand[0]
      c.type = "Prosperity::CountingHouse"
      c.save!
      
      c = @player.cards.deck[0]
      c.type = "BasicCards::Copper"
      c.location = "discard"
      c.save!
      c = @player.cards.deck(true)[0]
      c.type = "BasicCards::Copper"
      c.location = "discard"
      c.save!
      c = @player.cards.deck(true)[0]
      c.type = "BasicCards::Copper"
      c.location = "discard"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Counting House.*\(PA.*:/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Counting House\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Prosperity::CountingHouse/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Choose 2
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} returned 2 Copper cards/, email.body)
      assert_match(/Cash: 5/, email.body)
    end
    
    should "handle button on revealed cards" do
      c = @player.cards.hand[0]
      c.type = "Intrigue::Scout"
      c.save!
      
      c = @player.cards.deck[0]
      c.type = "BasicCards::Copper"
      c.save!
      c = @player.cards.deck[1]
      c.type = "BasicCards::Estate"
      c.save!
      c = @player.cards.deck[2]
      c.type = "BaseGame::Cellar"
      c.save!
      c = @player.cards.deck[3]
      c.type = "Intrigue::GreatHall"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Scout.*\(PA.*:/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Scout\./, email.body)
      assert_match(/#{@user.name} put Estate, Great Hall into their hand/, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Intrigue::Scout/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Card 1
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} placed Cellar 2nd from top/, email.body)
      assert_match(/ - #{@user.name} placed Copper on top of their deck/, email.body)
    end
    
    should "handle peeked buttons" do
      c = @player.cards.hand[0]
      c.type = "Seaside::Navigator"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Navigator \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Navigator\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Seaside::Navigator/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Choose keep
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Navigator \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} chose not to discard/, email.body)      
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Seaside::Navigator/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Card 1
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Navigator \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} placed Copper 5th from top/, email.body)
    end    
    
    should "handle peeked latin square" do
      c = @player.cards.hand[0]
      c.type = "Seaside::Lookout"
      c.save!
      
      c = @player.cards.deck[0]
      c.type = "BasicCards::Copper"
      c.save!
      c = @player.cards.deck[1]
      c.type = "BasicCards::Gold"
      c.save!
      c = @player.cards.deck[2]
      c.type = "BasicCards::Estate"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Lookout \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Lookout\./, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Seaside::Lookout/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Choose 2=>0 1=>2 0=>1
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/ - #{@user.name} discarded Copper/, email.body)
      assert_match(/ - #{@user.name} trashed Estate/, email.body)
      assert_match(/ - #{@user.name} put Gold back on/, email.body)
    end
    
    should "handle playing all treasures when Mint in game" do
      @game.piles[-1].update_attributes!(:card_type => "Prosperity::Mint")
      @game.piles[-1].cards.each {|c| c.type = "Prosperity::Mint"; c.save!}

      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Play treasure \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      treas_act = @player.active_actions(true)[0]
      assert_equal 'play_treasure', treas_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{treas_act.id}: None Play Simple Treasures
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Buy \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Copper, Copper, Copper/, email.body)
    end
    
    should "handle playing no treasures when Mint in game" do
      @game.piles[-1].update_attributes!(:card_type => "Prosperity::Mint")
      @game.piles[-1].cards.each {|c| c.type = "Prosperity::Mint"; c.save!}

      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Play treasure \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      treas_act = @player.active_actions(true)[0]
      assert_equal 'play_treasure', treas_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{treas_act.id}: None Stop Playing Treasures
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Buy \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no Treasures/, email.body)
    end
    
    should "handle playing a specific treasure when Mint in game" do
      @game.piles[-1].update_attributes!(:card_type => "Prosperity::Mint")
      @game.piles[-1].cards.each {|c| c.type = "Prosperity::Mint"; c.save!}
      c = @player.cards.hand[0]
      c.type = "BasicCards::Gold"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Play treasure \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      treas_act = @player.active_actions(true)[0]
      assert_equal 'play_treasure', treas_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{treas_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Play treasure \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Gold./, email.body)
    end
    
    should "handle playing a special treasure" do      
      c = @player.cards.hand[0]
      c.type = "Prosperity::Loan"
      c.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Play treasure \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      treas_act = @player.active_actions(true)[0]
      assert_equal 'play_treasure', treas_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{treas_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Trash or Discard Copper \(PA.*for 'Discard'/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Loan.\n - #{@user.name} revealed Copper/, email.body)
      
      sleep(1)
      resolve_act = @player.active_actions(true)[0]
      assert_match(/resolve_Prosperity::Loan/, resolve_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{resolve_act.id}: Choose 0.1
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Play treasure \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} chose to discard their Copper/, email.body)
    end
    
    should "be able to chat alone" do
      @player.emailed
      sleep(1)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Say: Look, @#{@ply_bob.name}, it's me, chatting!
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Chatted into Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your chat was accepted./, email.body)
      assert_match(/Chat since last update:\n - Alan said: Look, @#{@ply_bob.name}, it's me, chatting!/, email.body)
    end
    
    should "be able to chat alone repeatedly" do
      @player.emailed
      sleep(1)
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Say: Look, @#{@ply_bob.name}, it's me, chatting!
Say: Yep, chat chat chat
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Chatted into Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your chat was accepted./, email.body)
      assert_match(/Chat since last update:\n - Alan said: Look, @#{@ply_bob.name}, it's me, chatting!\n - Alan said: Yep,( chat){3}/, email.body)
    end
    
    should "be able to act and chat" do
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Say: Hey @#{@ply_chas.name}! Stuff
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      assert_match(/Buy \(PA/, email.body)
      assert_match(/Chat since last update:\n - Alan said: Hey @#{@ply_chas.name}! Stuff/, email.body)
    end
    
    should "be able to act and chat repeatedly" do
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Say: Hey @#{@ply_chas.name}! Stuff
Resolve PA #{play_act.id}: None
Say: Yep, stuff stuff stuff
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      assert_match(/Buy \(PA/, email.body)
      assert_match(/Chat since last update:\n - Alan said: Hey @#{@ply_chas.name}! Stuff\n - Alan said: Yep,( stuff){3}/, email.body)
    end
    
    should "handle causing game end" do
      @game.piles[-1].cards.destroy_all
      @game.piles[-2].cards.destroy_all
      @game.piles[0].cards[1,100].each(&:destroy)
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      play_act = @player.active_actions(true)[0]
      assert_equal 'buy', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Pile 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/#{@player.name} - Winner with #{@player.reload.score} points/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} bought #{@game.piles[0].card_type.readable_name}/, email.body)
    end
    
    should "receive email if another user causes us to need to act" do
      @user_bob.pbem = true
      @user_bob.save!
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      play_act = @player.active_actions(true)[0]
      assert_equal 'buy', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Pile 9
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      assert_equal 2, ActionMailer::Base.deliveries.length
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} bought #{@game.piles[9].card_type.readable_name}/, email.body)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user_bob.email], email.to
      assert_equal "free-dom: Your action is required: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user_bob.id}_#{@user_bob.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Play action \(PA/, email.body)
      assert_match(/Events since last update:\n - Game #{@game.name} created(.|\n)*#{@user.name} bought #{@game.piles[9].card_type.readable_name}/, email.body)
    end
    
    should "receive email if another user activates an existing action" do
      @user_bob.pbem = true
      @user_bob.save!
      
      c = @player.cards.hand[0]
      c.type = "BaseGame::Militia"
      c.save!
      
      @ply_chas.cards.hand[4].discard
      @ply_chas.cards.hand[3].discard
      
      @player.emailed
      @ply_bob.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Card 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Militia/, email.body)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user_bob.email], email.to
      assert_equal "free-dom: Your action is required: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user_bob.id}_#{@user_bob.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Discard.* \(PA/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played Militia/, email.body)
      
      sleep(1)
      militia_act = @ply_bob.active_actions[0]
      assert_match(/BaseGame::Militia/, militia_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user_bob.name}
Game Number: #{@game.id}
Resolve PA #{militia_act.id}: Card 0
EOF
      @base_mail.from = @user_bob.email
      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user_bob.id}_#{@user_bob.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
   
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user_bob.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user_bob.id}_#{@user_bob.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      
      sleep(1)
      militia2_act = @ply_bob.active_actions(true)[0]
      assert_match(/BaseGame::Militia/, militia2_act.expected_action)
      @base_mail.body = <<EOF
Username: #{@user_bob.name}
Game Number: #{@game.id}
Resolve PA #{militia2_act.id}: Card 0
EOF
      @base_mail.from = @user_bob.email
      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user_bob.id}_#{@user_bob.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
            
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Your action is required: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Buy \(PA/, email.body)      
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user_bob.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user_bob.id}_#{@user_bob.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)      
    end
    
    should "receive email if another player ends the game" do
      @user_bob.pbem = true
      @user_bob.save!
      
      @game.piles[-1].cards.destroy_all
      @game.piles[-2].cards.destroy_all
      @game.piles[0].cards[1,100].each(&:destroy)
      
      @player.emailed
      sleep(1)
      play_act = @player.active_actions[0]
      assert_equal 'play_action', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: None
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/Events since last update:\n - #{@user.name} played no action/, email.body)
      
      sleep(1)
      play_act = @player.active_actions(true)[0]
      assert_equal 'buy', play_act.expected_action
      @base_mail.body = <<EOF
Username: #{@user.name}
Game Number: #{@game.id}
Resolve PA #{play_act.id}: Pile 0
EOF

      params = HashWithIndifferentAccess.new({:message => @base_mail.to_s, 
              :disposable => "#{@user.id}_#{@user.hashed_email(6,8)}"})
      post :handle, params.merge(:signature => sign_message(params))
      
      assert_response(:success)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user.email], email.to
      assert_equal "free-dom: Success: Game '#{@game.name}'", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user.id}_#{@user.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Your request was successful./, email.body)
      assert_match(/#{@player.name} - Winner with #{@player.reload.score} points/, email.body)
      assert_match(/Events since last update:\n - #{@user.name} bought #{@game.piles[0].card_type.readable_name}/, email.body)
      
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements [@user_bob.email], email.to
      assert_equal "free-dom: Game '#{@game.name}' over", email.subject
      assert_same_elements([ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{@user_bob.id}_#{@user_bob.hashed_email(6,8)}@")], email.reply_to)
      assert_match(/Game '#{@game.name}' has ended\./, email.body)
      assert_match(/#{@player.name} - Winner with #{@player.reload.score} points/, email.body)
    end
  end
end
