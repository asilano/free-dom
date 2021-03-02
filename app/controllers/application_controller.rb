class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :add_clacks_overhead

  def index
  end

  private

  def add_clacks_overhead
    response.set_header('X-Clacks-Overhead', 'GNU Terry Pratchett')
  end
end
