class Player < ApplicationRecord
  belongs_to :game_session
  has_many :game_actions, dependent: :destroy

  def hand_cards_array
    JSON.parse(hand_cards || '[]')
  end

  def hand_cards_array=(cards)
    self.hand_cards = cards.to_json
  end

  def ai?
    player_type == 'ai'
  end

  def human?
    player_type == 'human'
  end

  def can_bet?(amount)
    chips >= amount && is_active && !is_folded
  end

  def bet(amount)
    return false unless can_bet?(amount)
    
    actual_bet = [amount, chips].min
    update(
      chips: chips - actual_bet,
      current_bet: current_bet + actual_bet,
      total_bet: total_bet + actual_bet
    )
    actual_bet
  end

  def fold
    update(is_folded: true, is_active: false)
  end

  def reset_for_new_round
    update(is_folded: false, is_active: true, current_bet: 0, total_bet: 0)
  end
end
