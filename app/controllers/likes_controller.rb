class LikesController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @chase = Chase.find(params[:chase_id])
    @like = current_user.likes.build(chase: @chase)
    
    if @like.save
      redirect_to @chase, notice: 'いいねしました'
    else
      redirect_to @chase, alert: 'いいねに失敗しました'
    end
  end
  
  def destroy
    @chase = Chase.find(params[:chase_id])
    @like = current_user.likes.find_by(chase_id: @chase.id)
    @like.destroy if @like
    redirect_to @chase, notice: 'いいねを解除しました'
  end
end

