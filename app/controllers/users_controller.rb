class UsersController < ApplicationController
  before_filter :ensure_settings, :only => [:show, :edit]
  before_filter :find_session
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all, :order => :name)
    @title = "Rankings"
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    if @user
      flash[:notice] = "You're already logged in!"
      redirect_to settings_path
    else
      @user = User.new
      @title = "Register new user"
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @user }
      end
    end    
  end
  
  # GET /users/1/edit
  def edit        
    @user = User.find(session[:user_id]) unless session[:user_id].nil?
    @title = "Preferences"
    
    if @user.nil?
      flash[:warning] = "Please log in"
      redirect_to games_path
    end
  end
  
  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    
    respond_to do |format|
      if @user.save        
        session[:user_id] = @user.reload.id
        cookie_login if params[:remember_me]
        @user.create_ranking
        format.html { redirect_to(:controller => :users, :action => "edit", :method => :get) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    
    respond_to do |format|
      if params[:id].to_i != session[:user_id]
        flash[:warning] = "Failed to update user #{@user.name} - not logged in as that user"
        format.html { redirect_to(:controller => :games, :action => :index) }
      elsif @user.update_attributes(params[:user])
        session[:user_id] = @user.id
        flash[:notice] = "Settings updated for #{@user.name}"
        format.html { redirect_to(:controller => :users, :action => "edit", :method => :get) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  # Handle login
  def login
    if request.post?
      @user = User.authenticate(params[:name], params[:password])
      if @user
        session[:user_id] = @user.id
        @user.save!
        cookie_login if params[:remember_me]
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || games_path)
      else
        flash.now[:warning] = "Invalid user/password combination"
      end
    else
      if @user
        flash[:notice] = "You're already logged in!"
        redirect_to settings_path
      else
        params[:name] = flash[:name]
        @title = "Login"
      end
    end      
  end
  
  def logout
    uncookie_login
    session[:user_id] = nil
    redirect_to(games_path)
  end  
  
  # Handle a forgotten password
  def password_reset
    if request.post?
      @user = User.find_by_name(params[:name])
      if @user
        new_pass = @user.reset_password
        UserMailer.password_reset(@user, new_pass).deliver
        flash[:notice] = "A new password has been sent to the email address on record for #{@user.name}"
        flash[:name] = params[:name] 
        redirect_to login_path        
      end
    else
      @title = "Reset password"
    end
  end
  
private
  
  def ensure_settings
    if params[:id]
      user = User.find(params[:id])
    elsif session[:user_id]
      user = User.find(session[:user_id])
    end
    
    if user and user.settings.nil?
      user.create_settings
    end
  end
  
  def find_session
    if session[:user_id]
      @user = User.find(session[:user_id])
    end
  end
end
