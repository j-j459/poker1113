class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true
  
  validates :user_id, uniqueness: { scope: [:votable_id, :votable_type], 
                                   message: 'has already voted on this item' }
  validates :value, inclusion: { in: [-1, 1], message: 'must be either 1 (upvote) or -1 (downvote)' }
  
  after_save :update_votable_votes_count
  after_destroy :update_votable_votes_count
  
  private
  
  def update_votable_votes_count
    if votable.respond_to?(:update_votes_count)
      votable.update_votes_count
    end
  end
end
