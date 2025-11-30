class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.references :game_session, null: false, foreign_key: true
      t.string :player_type, default: 'human'
      t.string :name
      t.integer :chips, default: 1000
      t.integer :position
      t.boolean :is_active, default: true
      t.boolean :is_folded, default: false
      t.string :hand_cards
      t.integer :current_bet, default: 0
      t.integer :total_bet, default: 0

      t.timestamps
    end
  end
end
