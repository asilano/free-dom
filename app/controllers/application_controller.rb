# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  before_filter :set_cache_headers
  before_filter :custom_headers
  before_filter :check_cookied_user
  before_filter :record_player_pa_ids

  after_filter {check_player_pa_ids; email_pbem_players}

  def nop
    render :text => ""
  end

protected
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
  end

  def custom_headers
    response.headers['X-Clacks-Overhead'] = 'GNU Terry Pratchett'
  end

  def check_cookied_user
    if cookies[:userId] && cookies[:userCode]
      begin
        u = User.find(cookies[:userId])
        if u && u.hashed_email == cookies[:userCode]
          session[:user_id] = u.id
          @user = u
          cookie_login
        end
      rescue
        uncookie_login
        session[:user_id] = nil
      end
    end
  end

  def cookie_login
    cookies[:userId] = {:value => @user.id.to_s, :expires => User.cookie_timeout.days.from_now}
    cookies[:userCode] = {:value => @user.hashed_email, :expires => User.cookie_timeout.days.from_now}
  end

  def uncookie_login
    cookies.delete :userId
    cookies.delete :userCode
  end

  def record_player_pa_ids
    @pa_ids = {}
    Player.all.each do |ply|
      @pa_ids[ply.id] = ply.pending_actions(true).active.pluck(:id)
    end
  end

  def check_player_pa_ids
    Game.current and Game.current.players.each do |ply|
      new_ids = ply.pending_actions(true).active.pluck(:id)
      diff = new_ids - (@pa_ids[ply.id] || [])

      if !diff.empty? && ply.user.pbem? &&
          (!Player.to_email[ply.id] || !Player.to_email[ply.id].include?(:game_state))
        Player.to_email[ply.id] ||= {}
        Player.to_email[ply.id][:game_state] = [:controls,
                                                "free-dom: Your action is required: Game '#{ply.game.name}'",
                                                "You are needed to take one or more actions in '#{ply.game.name}'.",
                                                nil]
      end
    end
  end

  def email_pbem_players
    Player.to_email.sort.each do |pid, mails|
      player = Player.find(pid)
      game = player.game
      user = player.user
      mails.each do |kind, args|
        while args.index(:controls)
          args[args.index(:controls)] = player.determine_controls
        end
        args = [user, game, player] + args

        # Ignore any errors thrown by the PBEM mail system - they don't impact
        # the game.
        begin
          PbemMailer.send("#{kind}".to_sym, *args).deliver
        rescue
        end
      end
      player.emailed
      player.save
    end
    Player.to_email = {}
  end

  def authorise
    unless @user
      flash[:warning] = "Please log in"
      session[:original_uri] = request.url if request.get?
      redirect_to login_path
      return false
    end
    true
  end

  def ensure_admin
    if authorise
      if !@user.admin?
        flash[:warning] = "You are not authorised to view that page"
        redirect_to games_path
        return false
      end
    else
      return false
    end
    true
  end

  def find_user
    @user = User.find_by_id(session[:user_id])
    @player = @user.players.find_by_game_id(@game.id) if (@game and @user)
  end

end
