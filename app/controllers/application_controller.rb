class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :add_clacks_overhead
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to :root
  end
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to new_user_session_path, status: 303
  end

  def index
  end

  helper_method :current_player
  def current_player
    return nil unless @game
    @current_player ||= @game.game_state&.player_for(current_user)
  end

  private

  def add_clacks_overhead
    response.set_header('X-Clacks-Overhead', 'GNU Terry Pratchett')
  end
end
