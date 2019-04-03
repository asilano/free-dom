class GamesController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game.process
  end

  # GET /games/new
  def new
    @game = Game.new
    @game.journals.build(type: GameEngine::ChooseKingdomJournal,
                         user: current_user,
                         order: 0)
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        @game.journals.create!(type: GameEngine::AddPlayerJournal, user: current_user, order: @game.journals.maximum(:order) + 1)
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def random_name
    render plain: helpers.random_game_name
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_params
    params.require(:game).permit(:name,
                                 journals_attributes: [
                                   :user_id,
                                   :type,
                                   :order,
                                   cards: []
                                 ])
  end
end
