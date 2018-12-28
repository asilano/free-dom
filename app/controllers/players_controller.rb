class PlayersController < ApplicationController
  def create
    # Check for an existing player of this game with this user
    @player = Player.find_or_initialize_by player_params.merge(user: current_user)

    respond_to do |format|
      notice = "Welcome to #{@player.game.name}" unless @player.persisted?
      if @player.persisted? || @player.save
        format.html { redirect_to @player.game, notice: notice }
      else
        format.html { redirect_to games_path, alert: 'Could not join game' }
      end
    end
  end

  private

  def player_params
    params.require(:player_params).permit(:game_id, :user_id)
  end
end