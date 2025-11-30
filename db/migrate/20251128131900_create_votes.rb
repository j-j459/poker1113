class CreateVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :votable, polymorphic: true, null: false
      t.integer :value, default: 0

      t.timestamps
    end

    add_index :votes, [:user_id, :votable_id, :votable_type], unique: true, name: 'index_votes_on_user_and_votable'
  end
end
