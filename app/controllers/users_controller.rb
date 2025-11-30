class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def show
    if params[:id] == 'sign_in'
      redirect_to new_user_session_path
      return
    end
    
    @user = User.find(params[:id])
  end
  
  def following
    @user = User.find(params[:id])
    @users = @user.followings
    render 'show_follow'
  end
  
  def followers
    @user = User.find(params[:id])
    @users = @user.followers
    render 'show_follower'
  end
end
