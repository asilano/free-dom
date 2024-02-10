class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :add_clacks_overhead
  before_action :set_current

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to :root
  end
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to new_user_session_path, status: 303
  end

  def index
  end

  private

  def add_clacks_overhead
    response.set_header('X-Clacks-Overhead', 'GNU Terry Pratchett')
  end

  def set_current
    Current.user = current_user
  end
end
