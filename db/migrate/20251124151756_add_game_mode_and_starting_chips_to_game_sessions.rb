class AddGameModeAndStartingChipsToGameSessions < ActiveRecord::Migration[6.1]
  def change
    add_column :game_sessions, :game_mode, :string
    add_column :game_sessions, :starting_chips, :integer
  end
end
