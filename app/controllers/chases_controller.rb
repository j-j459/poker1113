class ChasesController < ApplicationController
  
  before_action :authenticate_user!, only: [:new, :create]
  def top

  end

  def index
    @chases = Chase.includes(:user, :likes, :comments).order(created_at: :desc)
  
    if params[:search].present?
      @chases = @chases.where("body LIKE ?", "%#{params[:search]}%")
    end
    
    if params[:sort] == 'popular'
      @chases = @chases.left_joins(:likes).group('chases.id').order('COUNT(likes.id) DESC')
    end
    
    # kaminariが利用可能な場合のみページネーションを適用
    if defined?(Kaminari) && @chases.respond_to?(:page)
      @chases = @chases.page(params[:page]).per(10)
    else
      # kaminariが利用できない場合は全件表示（最大50件）
      @chases = @chases.limit(50)
    end
  end


  def new
        @chase = Chase.new
      end
    
      def create
        chase = Chase.new(chase_params)
        chase.user_id = current_user.id
        if chase.save
          redirect_to chase, notice: '投稿を作成しました'
        else
          render :new
        end
      end
      def show
        @chase = Chase.find(params[:id])
        @comments = @chase.comments.includes(:user).order(created_at: :desc)
        @comment = Comment.new
        @like = current_user&.likes&.find_by(chase_id: @chase.id) if user_signed_in?
      end
    
      def edit
        @chase = Chase.find(params[:id])
        unless @chase.user == current_user
          redirect_to @chase, alert: '他のユーザーの投稿は編集できません'
        end
      end

      def update
        chase = Chase.find(params[:id])
        unless chase.user == current_user
          redirect_to chase, alert: '他のユーザーの投稿は編集できません'
          return
        end
        
        if chase.update(chase_params)
          redirect_to chase, notice: '投稿を更新しました'
        else
          render :edit
        end
      end

      def destroy
        chase = Chase.find(params[:id])
        unless chase.user == current_user
          redirect_to chase, alert: '他のユーザーの投稿は削除できません'
          return
        end
        
        chase.destroy
        redirect_to chases_path, notice: '投稿を削除しました'
      end
      
      private
      def chase_params
        params.require(:chase).permit(:body, :ace, :king, :queen, :jack, :ten, :nine, :eight, :seven, :six, :five, :four, :three, :two, :one, :aa, :bb, :cc, :dd, :ee)
      end

end

