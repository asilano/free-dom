class GamesController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games
  # GET /games.json
  def index
    games = Game.all.each(&:process)
    games = games.group_by { |g| g.users.include?(current_user) ? :mine : :others }
    @games = games.transform_values do |g_group|
      g_group.group_by(&:run_state)
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game.process
    @game.notify_discord if flash[:notify_discord]
  end

  # GET /games/new
  def new
    @game = Game.new
    kingdom_journal = @game.journals.build(type:     GameEngine::ChooseKingdomJournal,
                                           user:     current_user,
                                           fiber_id: '1',
                                           params:   {},
                                           order:    0)
    kingdom_card_types = GameEngine::Card.expansions.map(&:kingdom_cards).flatten
    Rails.logger.info("kingdom_card_types holds: #{kingdom_card_types.inspect}")
    card_shaped_types = GameEngine::Card.randomised_card_shaped_things.map(&:card_classes).flatten
    Rails.logger.info("card_shaped_types holds: #{card_shaped_types.inspect}")
    randomiser = (kingdom_card_types + card_shaped_types).shuffle
    Rails.logger.info("randomiser holds: #{randomiser.inspect}")
    
    kingdom_cards, card_shapeds = randomiser.take_while.with_object([[], []]) do |card, sets|
      if card < GameEngine::Card
        sets[0] << card
      else
        sets[1] << card unless sets[1].length >= 2
      end
      sets[0].length < 10
    end
    kingdom_journal.params["card_list"] = kingdom_cards.sort_by(&:raw_cost) + card_shapeds
  end

  # POST /games
  # POST /games.json
  def create
    return refresh_form if params["add-fields"] || params["delete-fields"]

    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        @game.discord_log_creation
        @game.journals.create!(type:     GameEngine::AddPlayerJournal,
                               user:     current_user,
                               fiber_id: '1',
                               order:    @game.journals.maximum(:order) + 1)
        flash[:notify_discord] = true

        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /games/1
  # PATCH /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :show, alert: 'Game update failed' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    respond_to do |format|
      if @game.journals.first.user == current_user && @game.destroy
        format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      else
        format.html { redirect_to games_url, alert: 'Could not destroy game.' }
      end
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
                                 :discord_webhook,
                                 journals_attributes: [
                                   :user_id,
                                   :type,
                                   :order,
                                   :fiber_id,
                                   params: {}
                                 ])
  end

  def refresh_form
    @game = Game.new(game_params)
    if params["add-fields"]
      @game.journals.first.params["card_list"] << ""
    elsif params["delete-fields"]
      @game.journals.first.params["card_list"].delete_at(params["delete-fields"].to_i)
    end
    respond_to do |format|
      format.html { render :new }
      format.turbo_stream { render :refresh_form }
    end
  end
end
