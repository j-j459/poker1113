class GameAction < ApplicationRecord
  belongs_to :game_session
  belongs_to :player

  enum action_type: { 
    fold: 'fold', 
    check: 'check', 
    call: 'call', 
    bet: 'bet', 
    raise: 'raise', 
    all_in: 'all_in' 
  }
end
