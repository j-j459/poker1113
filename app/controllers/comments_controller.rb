class CommentsController < ApplicationController
    before_action :authenticate_user!

    def create
      chase = Chase.find(params[:chase_id])
      comment = chase.comments.build(comment_params)
      comment.user_id = current_user.id
      if comment.save
        redirect_to chase, notice: "コメントしました"
      else
        redirect_to chase, alert: "コメントできませんでした"
      end
    end
  
    private
  
      def comment_params
        params.require(:comment).permit(:content)
      end
end
