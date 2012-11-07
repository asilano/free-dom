class PbemMailer < ActionMailer::Base

  helper :games
  helper :pbem

  AdminAddr = 'chowlett09+free-dom@gmail.com'
  default :from => "Free-Dom <#{AdminAddr}>"

  def bad_user_error(to_addr, old_msg)
    @old_msg = old_msg

    mail :subject => "Failed: #{old_msg.subject}",
         :to => to_addr
  end

  def game_not_found(user, game_id, old_msg)
    @user = user
    @game_id = game_id
    @rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    @old_msg = old_msg

    mail :subject => 'free-dom: Couldn\'t find game',
         :to => user.email,
         :reply_to  => @rep_add
  end

  def game_params(user, game)
    @user = user
    @game = game
    @rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")

    mail :subject => 'free-dom: Confirm / Modify New Game Details',
         :to => user.email,
         :reply_to => @rep_add
  end

  def game_create_error(user, game, old_msg)
    @user = user
    @game = game
    @rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    @old_msg = old_msg

    mail :subject => 'free-dom: Errors in New Game request',
         :to => @user.email,
         :reply_to => @rep_add
  end

  def game_state(user, game, player, controls, subj, text, warn)
    @user = user
    @game = game
    @player = player
    @controls = controls
    @text = text
    @warn = warn

    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    mail :subject => subj,
         :to => user.email,
         :reply_to  => rep_add
  end

  def player_joined(user, game, player, new_player)
    @user = user
    @game = game
    @player = player
    @new_player = new_player

    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    mail :subject => "free-dom: #{new_player.name} joined '#{game.name}'",
         :to => user.email,
         :reply_to  => rep_add
  end

  def game_error(user, game, player, controls, rc, msg)
    @user = user
    @game = game
    @player = player
    @controls = controls
    @rc = rc
    @old_msg = msg
    @rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")

    mail :subject => "free-dom: Problem with your request",
         :to => user.email,
         :reply_to  => @rep_add
  end

  def game_exception(user, game, error)
    body = "#{user.name} experienced an exception while playing in game number #{game.id}\n"
    body << "The exception was: #{error.inspect}\n\n"
    body << "Backtrace:\n"
    body << "  " + error.backtrace.join("\n  ")

    mail :subject => "Exception in free-dom PBEM", :to => AdminAddr do |format|
      format.text { render :text => body }
    end
  end
end
