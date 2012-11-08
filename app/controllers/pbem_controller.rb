class PbemController < ApplicationController

  include AgnosticGameController

  require 'mail'
  skip_before_filter :verify_authenticity_token
  before_filter :verify_signature, :only => :handle

  rescue_from Exception, :with => :error_reply

  SECRET = ENV['CLOUDMAILIN_SECRET'] || '46075664a79b141cfbac'

  def handle
    render :text => "Handled"

    # Parse the message.
    @message = Mail.new(params[:message])

    # Try to pick up the user
    body = @message.body.to_s
    body =~ /^[ \t]*Username: (\w*)/m
    username = $1
    @user = User.find_by_name(username)

    if @user
      # Try to validate the disposable part of the email.
      expect_disp = "#{@user.id}_#{@user.hashed_email(6,8)}"
      if params[:disposable] != expect_disp
        @user = nil
      end
    end

    if @user.nil?
      # Bad user. No cookie for you
      PbemMailer.bad_user_error(@message.reply_to || @message.from, @message).deliver
      return
    end

    # Work out what this email looks like.
    case body
    when /^\s*Action: Create game/i
      create(body)
    when /^\s*Action: Start Game/i
      start_game(body)
    when /^\s*Action: Join Game/i
      join_game(body)
    when /^\s*Resolve PA \d+/i
      resolve_actions(body)
    when /^Say: /i
      find_game_and_player(body)
      if @game && @user
        non_ply_name = @user.name if !@player

        body.scan(/^Say: (.*)$/i) do |statement,|
          @game.chats.create(:player => @player,
                             :non_ply_name => non_ply_name,
                             :turn => @game.turn_count || 0,
                             :turn_player => @game.current_turn_player,
                             :statement => statement)
        end
        process_result "OK",
                       "free-dom: Chatted into Game '#{@game.name}'",
                       "Your chat was accepted."
      else
        PbemMailer.game_error(@user, @game, @player, @controls, "Unable to chat without both game and user", @message).deliver
      end
    else
      find_game_and_player(body)
      @controls = @player.determine_controls if @player
      PbemMailer.game_error(@user, @game, @player, @controls, "Couldn't work out what to do with your request", @message).deliver
    end
  end

protected

  def verify_signature
    provided = request.request_parameters.delete(:signature)
    signature = Digest::MD5.hexdigest(flatten_params(request.request_parameters).sort_by {|p| p[0].to_s}.map{|k,v| v}.join + SECRET)

    if provided != signature
      render :text => "Message signature fail #{provided} != #{signature}", :status => 403, :content_type => Mime::TEXT.to_s
      return false
    end
  end

  def flatten_params(params, title = nil, result = {})
    params.each do |key, value|
      if value.kind_of?(Hash)
        key_name = title ? "#{title}[#{key}]" : key
        flatten_params(value, key_name, result)
      else
        key_name = title ? "#{title}[#{key}]" : key
        result[key_name] = value
      end
    end

    return result
  end

private
  def create(body)
    # Extract game creation parameters from the email
    game_params = {}

    /Game name:[ \t]*(.+)/i =~ body
    game_params[:name] = $1.strip if $1

    /Max players:[ \t]*(\d+)/i =~ body
    game_params[:max_players] = $1

    /Random:[ \t]*(true|false)/i =~ body
    game_params[:random_select] = ($1 == 'true') ? 1 : 0

    (1..10).each do |ix|
      /Kingdom card #{ix}:[ \t]*(?#Module)(\w+)[ \t]*(?#Optional Separator)(?:-|::)?[ \t]*(?#Card Name)([\w ]+)/i =~ body
      game_params["pile_#{ix}".to_sym] = "#{$1}::#{$2.delete(" ").classify}" if ($1 && $2)
    end

    /Distribution:[ \t]*(true|false)/i =~ body
    game_params[:specify_distr] = ($1 == 'true') ? 1 : 0

    %w<BaseGame Intrigue Seaside Prosperity>.each do |set|
      /#{set}:[ \t]*(\d+)/i =~ body
      game_params["num_#{set.underscore}_cards".to_sym] = $1

      /#{set}:[ \t]*(true|false)/i =~ body
      game_params["#{set.underscore}_present".to_sym] = ($1 == 'true') ? 1 : 0
    end

    /Platinum.*Colony:[ \t]*(yes|no|rules)/i =~ body
    game_params[:plat_colony] = $1

    res = ag_create(game_params)

    case res
    when :invalid
      PbemMailer.game_create_error(@user, @game, @message).deliver
    when :tweak
      PbemMailer.game_params(@user, @game).deliver
    when :created
      process_result "OK",
                     "free-dom: Game '#{@game.name}' Created",
                     "Your game '#{@game.name}' was created successfully. The game state is below.\nYou will receive further emails when more players join the game."
    end
  end

  def start_game(body)
    find_game_and_player(body)

    rc = nil
    Game.transaction { rc = @game.start_game }
    process_result rc,
                   "free-dom: Game '#{@game.name}' Started",
                   "The game '#{@game.name}' has been started. The game state is below.\nYou will receive further emails when it is your turn to act."
  end

  def join_game(body)
    find_game_and_player(body)

    res = ag_join

    case res
    when :already
      process_result "OK Already playing in #{@game.name}",
                     "free-dom: Already in #{@game.name}",
                     "You are already playing in #{@game.name}."
    when :joined
      @player = @user.players.find_by_game_id(@game.id)
      process_result "OK",
                     "free-dom: Joined Game '#{@game.name}'",
                     "You have successfully joined game '#{@game.name}'."
    when :failed
      # ... can't be arsed to handle this.
    end
  end

  def resolve_actions(body)
    # Resolve PA message. It's legal to try to resolve multiple Pending Actions at once
    find_game_and_player(body)
    return unless @game && @player
    overall_ret = "OK "
    Game.transaction do
      body.scan(/^\s*Resolve PA (\d+): (.*)/i) do |pa_id, choice|
        pa = nil
        begin
          pa = PendingAction.find(pa_id.to_i)
        rescue ActiveRecord::RecordNotFound
          process_result "Could not find Pending Action number #{pa_id}", nil, nil
          raise ActiveRecord::Rollback
        end

        if !@player.active_actions.include? pa
          process_result "Not expecting you to #{pa.text} at this time"
          raise ActiveRecord::Rollback
        end

        args = {}
        choice.strip!
        if choice =~ /^None/
          args[:nil_action] = choice[/^None (.*)/, 1] || true
        else
          choice =~ /^([\S]*) (.*)/
          type = $1
          value = $2
          key = case type
            when "Card", "card"
              :card_index
            when "Pile", "pile"
              :pile_index
            when "Choose", "choose"
              :choice
            when nil, ""
              nil
            else
              type.downcase.to_sym
            end
          if !key
            process_result "Didn't understand your choice #{choice} for PA #{pa_id}", nil, nil
            raise ActiveRecord::Rollback
          end
          if value =~ /^\[(.*)\]/
            value = $1.split(/,\s*/)
          elsif value =~ /^\{(.*)\}/
            choices = $1.split(/,\s*/)
            if choices.all? {|v| v =~ /.*=>.*/}
              value = choices.each_with_object({}) do |v, h|
                v =~ /(.*)=>(.*)/
                h[$1.strip] = $2.strip
              end
            end
          end
          args[key] = value
        end

        rc = nil
        case pa.expected_action
        when "play_action"
          rc = @player.play_action(args)
        when "buy"
          rc = @player.buy(args)
        when "play_treasure"
          rc = @player.play_treasure(args)
        when /resolve_([[:alpha:]]+::[[:alpha:]]+[0-9]+)_?([[:alnum:]]+)?(;.+)?/
          # Ironically, we need to break down the expected action into its component parts
          # so that Player#resolve can build it back up again. Sigh.
          args[:card] = $1
          if $2
            args[:substep] = $2
          end
          param_string = $3
          if param_string
            param_string.scan(/;([^;=]*)=([^;=]*)/) {|m| args[m[0].to_sym] = m[1]}
          end
          puts args.inspect
          rc = @player.resolve(args)
        end

        if rc =~ /^OK ?(.*)?/
          overall_ret << "#{$1}\n" if $1
        else
          process_result rc, nil, nil
          raise ActiveRecord::Rollback
        end
      end

      # Handle any chats along for the ride
      body.scan(/^Say: (.*)$/i) do |statement,|
        @game.chats.create(:player => @player,
                           :non_ply_name => nil,
                           :turn => @game.turn_count || 0,
                           :turn_player => @game.current_turn_player,
                           :statement => statement)
      end

      process_result overall_ret,
             "free-dom: Success: Game '#{@game.name}'",
             "Your request was successful. The updated game state is below"
    end
  end

  def process_result(rc, subject, text)

    @game.process_actions if @game
    @controls = @player.determine_controls if @player
    if rc =~ /^OK ?(.*)?/
      warn = $1
      Player.to_email[@player.id] ||= {}
      Player.to_email[@player.id][:game_state] = [:controls,
                                                 subject,
                                                 text,
                                                 warn]
    else
      Player.to_email[@player.id] ||= {}
      Player.to_email[@player.id][:game_error] = [:controls,
                                                 rc,
                                                 @message]
    end
  end

  def find_game_and_player(body)
    /^\s*Game Number:[ \t]*(\d+)/i =~ body
    game_id = $1.to_i

    begin
      @game = Game.find(game_id)
      Game.current = @game
    rescue ActiveRecord::RecordNotFound
      PbemMailer.game_not_found(@user, game_id, @message).deliver
    end

    @player = @user.players.find_by_game_id(@game.id) if (@game and @user)

    if !@player
      PbemMailer.game_error(@user, @game, nil, nil, "You are not a player in Game #{@game.id}", body).deliver
    end
  end

  def error_reply(error)
    if @user
      if @game
        PbemMailer.game_error(@user, @game, @player, nil, "Sorry, something went wrong. The webmaster has been alerted", @message.body.to_s).deliver
        PbemMailer.game_exception(@user, @game, error).deliver
      else
        PbemMailer.game_not_found(@user, "unknown", @message).deliver
      end
    else
      PbemMailer.bad_user_error(@message.reply_to || @message.from, @message).deliver
    end

    return
  end
end
