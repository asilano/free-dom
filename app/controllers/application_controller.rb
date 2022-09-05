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

  private

  def add_clacks_overhead
    response.set_header('X-Clacks-Overhead', 'GNU Terry Pratchett')
  end
end
