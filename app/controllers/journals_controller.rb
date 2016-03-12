class JournalsController < ApplicationController
  before_action :set_journal, only: [:show, :edit, :update, :destroy]
  before_action :find_game, only: [:create, :update]
  before_action :find_user, only: [:create, :update]

  # GET /journals
  def index
    @journals = Journal.all
  end

  # GET /journals/1
  def show
  end

  # GET /journals/new
  def new
    @journal = Journal.new
  end

  # GET /journals/1/edit
  def edit
  end

  # POST /journals
  def create
    if params[:journal] && params[:journal][:event] && @game
      new_order = params[:journal][:order].andand.to_i
      if new_order && @game.journals.any? { |j| j.order == new_order }
        # Inserting a journal. Renumber all following journals
        @game.journals.where { order >= new_order }.each do |j|
          j.order += 1
          j.save!
        end
      end

      @journal = @game.journals.build(journal_params)
      @journal.player = @player
      if !@journal.order
        @journal.order = @journal.game.journals.map(&:order).max + 1
      end

      @journal.save
    end
    respond_to do |format|
        format.html { redirect_to play_game_path(@game), status: :see_other }
        format.json { respond_with_bip(@journal) }
    end
  end

  # PATCH/PUT /journals/1
  def update
    if params[:journal].andand[:event].andand.blank?
      @journal.destroy
    else
      @journal.update(journal_params)
    end
    respond_to do |format|
        format.html { redirect_to play_game_path(@journal.game), status: :see_other }
        format.json { respond_with_bip(@journal) }
    end

  end

  # DELETE /journals/1
  def destroy
    @journal.destroy
    redirect_to journals_url, notice: 'Journal was successfully destroyed.'
  end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_journal
      @journal = Journal.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def journal_params
      params[:journal].permit :game_id, :event, :order
    end
end
