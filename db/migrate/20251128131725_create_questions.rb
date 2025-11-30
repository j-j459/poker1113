class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.string :title
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.integer :views_count

      t.timestamps
    end
  end
end
