class Question < ApplicationRecord
  belongs_to :user
  belongs_to :best_answer, class_name: 'Answer', optional: true
  has_many :answers, dependent: :destroy
  has_many :question_tags, dependent: :destroy
  has_many :tags, through: :question_tags
  
  validates :title, presence: true, length: { minimum: 10, maximum: 200 }
  validates :content, presence: true, length: { minimum: 20 }
  validates :views_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  
  before_validation :set_default_views_count
  
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :unanswered, -> { left_joins(:answers).where(answers: { id: nil }) }
  scope :answered, -> { joins(:answers).distinct }
  
  def increment_views!
    increment!(:views_count)
  end
  
  def mark_as_best_answer(answer)
    update(best_answer: answer)
  end
  
  def has_best_answer?
    best_answer.present?
  end
  
  private
  
  def set_default_views_count
    self.views_count ||= 0
  end
