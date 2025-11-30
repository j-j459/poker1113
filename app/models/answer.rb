class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question, counter_cache: true
  has_many :votes, as: :votable, dependent: :destroy
  
  validates :content, presence: true, length: { minimum: 10 }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :top_voted, -> { left_joins(:votes).group(:id).order('COUNT(votes.id) DESC') }
  
  def is_best_answer?
    question.best_answer_id == id
  end
  
  def vote_count
    votes.sum(:value)
  end
  
  def upvote(user)
    vote = votes.find_or_initialize_by(user: user)
    vote.value = 1
    vote.save
  end
  
  def downvote(user)
    vote = votes.find_or_initialize_by(user: user)
    vote.value = -1
    vote.save
  end
  
  def remove_vote(user)
    votes.where(user: user).destroy_all
  end
end