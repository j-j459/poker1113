class Tag < ApplicationRecord
  has_many :question_tags, dependent: :destroy
  has_many :questions, through: :question_tags
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }, 
                   length: { maximum: 50 },
                   format: { with: /\A[a-zA-Z0-9+\-#.]*\z/, 
                            message: 'only allows letters, numbers, +, -, # and .' }
  
  before_validation :downcase_name
  
  scope :popular, -> { joins(:questions).group('tags.id').order('COUNT(questions.id) DESC') }
  
  def self.find_or_create_normalized(name)
    normalized_name = name.to_s.downcase.strip
    find_or_create_by(name: normalized_name)
  end
  
  private
  
  def downcase_name
    self.name = name.downcase if name.present?
  end
end
