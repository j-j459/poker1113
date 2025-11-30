class CreateGameActions < ActiveRecord::Migration[6.1]
  def change
    create_table :game_actions do |t|
      t.references :game_session, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :action_type
      t.integer :amount, default: 0
      t.string :game_phase
      t.integer :round_number

      t.timestamps
    end
  end
end
