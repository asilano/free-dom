class JournalsController < ApplicationController
  before_action :set_journal, only: :destroy

  # POST /journals
  # POST /journals.json
  def create
    @journal = Journal.new(journal_params)
    @journal.user_id ||= current_user.id

    respond_to do |format|
      format.html { redirect_to @journal.game }

      if @journal.save
        flash[:notify_discord] = true
        @game = @journal.game
        @game.process
        GameUpdateChannel.send_game_updates(@game)

        format.json { render :show, status: :created, location: @journal }
        format.turbo_stream do
          @game.notify_discord
          render "games/redraw"
        end
      else
        flash.alert = "Couldn't create journal (was the game up-to-date?)"
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journals/1
  # DELETE /journals/1.json
  def destroy
    @game = @journal.game
    to_destroy = @game.journals.where('journals.order >= ?', @journal.order)
    to_destroy.destroy_all
    @game.process

    GameUpdateChannel.send_game_updates(@game)

    respond_to do |format|
      format.html { redirect_to @game }
      format.json { head :no_content }
      format.turbo_stream do
        render "games/redraw"
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_journal
    @journal = Journal.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def journal_params
    params.require(:journal).permit(:game_id, :user_id, :order, :type, :fiber_id, params: {})
  end
end
