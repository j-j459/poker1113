class QuestionTag < ApplicationRecord
  belongs_to :question
  belongs_to :tag
  
  validates :question_id, uniqueness: { scope: :tag_id, message: 'already has this tag' }
  
  after_create :increment_tag_questions_count
  after_destroy :decrement_tag_questions_count
  
  private
  
  def increment_tag_questions_count
    tag.increment!(:questions_count) if tag.respond_to?(:questions_count)
  end
  
  def decrement_tag_questions_count
    tag.decrement!(:questions_count) if tag.respond_to?(:questions_count) && tag.questions_count.positive?
  end
