class PbemMailer < ActionMailer::Base

  helper :games
  helper :pbem
  
  def bad_user_error(to_addr, old_msg)
    subject    "Failed: #{old_msg.subject}"
    recipients to_addr
    from       'Free-Dom <chowlett09+free-dom@gmail.com>'
    sent_on    Time.now
    body       :old_msg => old_msg
  end
  
  def game_not_found(user, game_id, old_msg)
    subject    'free-dom: Couldn\'t find game'
    recipients user.email
    from       'Free-Dom <chowlett09+free-dom@gmail.com>'
    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    reply_to   rep_add
    sent_on    Time.now
    body       :user => user, :game_id => game_id, :rep_add => rep_add, :old_msg => old_msg
  end
  
  def game_params(user, game)
    subject    'free-dom: Confirm / Modify New Game Details'
    recipients user.email
    from       'Free-Dom <chowlett09+free-dom@gmail.com>'
    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    reply_to   rep_add
    sent_on    Time.now
    body       :user => user, :game => game, :rep_add => rep_add
  end

  def game_create_error(user, game, old_msg)
    subject    'free-dom: Errors in New Game request'
    recipients user.email
    from       'Free-Dom <chowlett09+free-dom@gmail.com>'
    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    reply_to   rep_add
    sent_on    Time.now
    body       :user => user, :game => game, :rep_add => rep_add, :old_msg => old_msg
  end
  
  def game_state(user, game, player, controls, subj, text, warn)
    subject    subj
    recipients user.email
    from       'Free-Dom <chowlett09+free-dom@gmail.com>'
    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    reply_to   rep_add
    sent_on    Time.now
    body       :user => user, :game => game, :player => player, :controls => controls, :text => text, :warn => warn
  end
  
  def player_joined(user, game, player, new_player)
    subject     "free-dom: #{new_player.name} joined '#{game.name}'"
    recipients  user.email
    from        'Free-Dom <chowlett09+free-dom@gmail.com>'
    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    reply_to    rep_add
    sent_on     Time.now
    body        :user => user, :game => game, :new_player => new_player, :player => player
  end
  
  def game_error(user, game, player, controls, rc, msg)
    subject     "free-dom: Problem with your request"
    recipients  user.email
    from        'Free-Dom <chowlett09+free-dom@gmail.com>'
    rep_add = ENV['CLOUDMAILIN_FORWARD_ADDRESS'].sub(/@/, "+#{user.id}_#{user.hashed_email(6,8)}@")
    reply_to    rep_add
    sent_on     Time.now
    body        :user => user, :game => game, :player => player, :rc => rc, :old_msg => msg, :rep_add => rep_add, :controls => controls
  end
end
