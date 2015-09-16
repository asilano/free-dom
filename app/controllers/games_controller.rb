class GamesController < ApplicationController

  include AgnosticGameController

  # Filters:
  # * For every action relating to a game, find the game
  # * For every action which may make use of a user, pick up the user
  # * For every action requiring login, authorise the user
  # * In all cases, set up the HTML title string.
  before_filter :find_game, :except => [:index, :new, :create, :card_text]
  before_filter :find_user, :except => [:card_text]
  before_filter :legacy
  before_filter :authorise, :except => [:index, :watch, :speak, :check_change, :card_text]
  before_filter :setup_title, :except => [:card_text]

  around_filter :lock_player, :only => [:buy, :play_action, :resolve]

  #around_filter do |ctrlr, act|
  #  Game.transaction do
  #    act.call
  #  end
  #end

  def legacy
    if @user.andand.name == 'Clive'
      self.class.prepend_view_path "app/views/old"
    else
      self.class.view_paths = ['app/views']
    end
  end

  # GET /games
  # GET /games.xml
  def index
    @games = Game.all.sort_by(&:id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end

  # GET /games/1/watch
  # Watch a game; that is, see all the public information, but no player-private
  # information
  def watch
    @player = nil
    @controls = Hash.new([])
    @last_mod = @game.last_modified
    headers["Last-Modified"] = @last_mod.httpdate

    @title = "Watching game '#{@game.name}'"
    render :action => :show
  end

  # GET /games/1/play
  # Play a game; that is, see all the public information, together with the
  # player-private information associated with the current session
  def play
    @game.process_actions
    @controls = (@player ? @player.determine_controls : Hash.new([]))
    @last_mod = @game.last_modified
    headers["Last-Modified"] = @last_mod.httpdate

    setup_full_title

    render :action => :show
    @unloadFunc = nil
  end

  def join
    res = ag_join

    case res
    when :already
      redirect_to :action => :play, :id => @game
    when :joined
      redirect_to :action => :play, :id => @game
    when :failed
      flash[:error] &&= '<br/>' + flash[:error]
      flash[:error] ||= ""
      flash[:error] += 'Failed to join game as a player'
      if @game.state != "waiting"
        flash[:error] += "<br/>Game is #{@game.state}"
      end
      redirect_to :action => :watch, :id => @game
    end
  end

  # GET /games/new
  # GET /games/new.xml
  def new
    @game = Game.new
    @game.max_players = 6
    @game.random_select = 0
    @game.specify_distr = 1
    @game.plat_colony = "rules"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game }
    end
  end

  # POST /games
  # POST /games.xml
  def create
    res = ag_create(params[:game])

    case res
    when :invalid, :tweak
      render :action => 'new'
    when :created
      flash[:notice] &&= '<br/>' + flash[:notice]
      flash[:notice] ||= ""
      flash[:notice] += 'Game was successfully created.'
      redirect_to :action => :play, :id => @game
    end
  end

  def start_game
    # Call through to the game's controller to start the game
    rc = nil
    Game.transaction {rc = @game.start_game}
    process_result rc
  end

  def play_action
    handle_generic_ajax(:play_action)
  end

  def play_treasure
    handle_generic_ajax(:play_treasure)
  end

  def buy
    handle_generic_ajax(:buy)
  end

  def end_turn
    handle_generic_ajax(:end_turn)
  end

  def choose_sot_card
    handle_generic_ajax(:choose_sot_card)
  end

  def resolve
    handle_generic_ajax(:resolve)
  end

  # POST /games/1/speak
  def speak
    non_ply_name = ((@user && @user.name) || params[:name]) if !@player
    non_ply_name = "someone" if (non_ply_name.blank? && !@player)
    line = @game.chats.create(:player => @player,
                              :non_ply_name => non_ply_name,
                              :turn => @game.turn_count || 0,
                              :turn_player => @game.current_turn_player,
                              :statement => params[:say])

    respond_to do |format|
      format.html {redirect_to :back}
      format.js {render :partial => 'update_chat'}
    end

  end

  # DELETE /games/1
  # DELETE /games/1.xml
  def destroy
    @game.destroy

    respond_to do |format|
      format.html { redirect_to(games_url) }
      format.xml  { head :ok }
    end
  end

  # GET /games/1/check_change?since=<httpdate>
  def check_change
    # (XHR) request to update the page if anything has changed since the
    # specified time. Updates the last-checked element if no change
    @just_checking = true
    since_time = Time.httpdate(params[:since])

    if @game.last_modified >= since_time
      # Game state has changed. Call process_result to update the game state
      process_result("OK", false)
    else
      # No change. Render nothing, but do ensure the Last-Modified header is set
      @last_mod = @game.last_modified
      headers["Last-Modified"] = @last_mod.httpdate
      respond_to do |format|
        format.js { render :action => 'update_last_checked' }
      end
    end
  end

  def update_player_settings
    @player.settings.update_attributes(params[:settings])

    respond_to do |format|
      format.js do
        if params[:settings].include?(:update_interval)
          render :action => 'updated_refresh_interval'
        end
      end

      format.html { redirect_to :back}
    end
  end

  def card_text
    card_class = params[:type].constantize
    respond_to do |format|
      format.js { render :text => card_class.text }
    end
  end

protected
  def find_game
    @game = Game.find(params[:id])
    Game.current = @game
    @omit_onload = false
    @just_checking = false
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Attempt to access non-existant game #{params[:id]}" )
    flash[:warning] = "That Game doesn't exist"
    redirect_to :action => 'index'
  end

  def setup_title
    @title = action_name.humanize
  end

private
  def handle_generic_ajax(sym)
    if @player
      if @game == @player.game
        rc = nil
#        begin
          Game.transaction do
            rc = @player.send(sym, params)
            if rc !~ /^OK/
              # Force an exception in the transaction, to spawn a rollback
              rc = "#{rc}<br />Params: #{params.inspect}"
              raise ActiveRecord::Rollback
            end
          end
#        rescue => e
#          if e.message != "Play Action action failed"
#            raise
#          end
#        end
      else
        rc = "Error! Game and player mismatch!"
      end
    else
      rc = "You've lost your session details. Please log in again."
    end
    process_result rc
  end

  def process_result(rc, do_actions = true)
    if rc =~ /^OK ?(.*)?/
      flash[:warning] = $1 if $1 != ""

      @game.process_actions if do_actions
      if not @player.nil?
        @controls = @player.determine_controls
      else
        @controls = Hash.new([])
      end

      @last_mod = @game.last_modified
      setup_full_title
      headers["Last-Modified"] = @last_mod.httpdate

      respond_to do |format|
        format.js { render :action => 'update_game' }
        format.html { redirect_to :back }
      end
    else
      flash[:warning] = rc
      respond_to do |format|
        format.js { render :action => 'update_flash' }
        format.html { redirect_to :back }
      end
    end
  end

  def setup_full_title
    @full_title = ""

    if @game.state == 'running'
      waiting_players = @game.active_ply_actions.map {|a| a.player}

      # Ensure the current player is on the front of the list.
      if waiting_players.delete(@player)
        waiting_players.unshift(@player)
      end

      @full_title = waiting_players.map{|p| p.name }.join(', ')
      @full_title += " to act - "
      @full_title += @game.current_turn_player.name
      @full_title += "'s turn - "
    elsif @game.state == 'waiting'
      @full_title += "Waiting to start '#{@game.name}' - "
    elsif @game.state == 'ended'
      @full_title += "Ended game '#{@game.name}' - "
    end

    if @player
      @full_title += "#{@player.name} playing in Dominion game '#{@game.name}'"
    else
      @full_title += "Watching Dominion game '#{@game.name}'"
    end

  end

  def lock_player
    if !@player
      process_result "You've lost your session details. Please log in again."
    end

    if @player.reload.lock
      respond_to do |format|
        flash[:warning] = "Request outstanding"
        @omit_onload = true
        format.js { render :action => 'update_flash', :status => 423 }
      end
    else
      @player.lock = true
      @player.save!
      begin
        yield
      ensure
        @player.lock = false
        @player.save!
      end
    end
  end

end