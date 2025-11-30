class AddDeckToGameSessions < ActiveRecord::Migration[6.1]
  def change
    add_column :game_sessions, :deck, :text
    # community_cardsを公開済みカード専用に変更
    change_column_default :game_sessions, :community_cards, from: nil, to: '[]'
  end
end
