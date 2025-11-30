class AddBestAnswerToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_reference :questions, :best_answer, null: true, foreign_key: { to_table: :answers }
  end
end
