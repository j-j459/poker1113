class Like < ApplicationRecord
  belongs_to :user
  belongs_to :chase
  validates :user_id, uniqueness: { scope: :chase_id }
end

