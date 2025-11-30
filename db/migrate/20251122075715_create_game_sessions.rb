class CreateGameSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :game_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'waiting'
      t.integer :pot, default: 0
      t.integer :current_bet, default: 0
      t.integer :dealer_position, default: 0
      t.integer :small_blind, default: 10
      t.integer :big_blind, default: 20
      t.integer :current_player_position
      t.string :community_cards
      t.string :game_phase, default: 'preflop'
      t.integer :round_number, default: 1

      t.timestamps
    end
  end
end
