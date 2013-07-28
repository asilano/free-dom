class AnnouncementsController < ApplicationController
  before_filter :find_user
  before_filter :ensure_admin

  # GET /announcements/new
  # GET /announcements/new.json
  def new
    @title = "Send announcement"

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /announcements
  # POST /announcements.json
  def create
    recipients = if params[:annOverride]
      User.all
    else
      User.where(['contact_me = ?', true])
    end

    recipients.each do |u|
      UserMailer.announce(u, params[:annText], {:subject => params[:annSubject], :override => params[:annOverride]}).deliver
    end

    flash[:notice] = 'Announcement sent!'
    respond_to do |format|
      format.html { redirect_to action: "new" }
    end
  end
end
