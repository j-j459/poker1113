class PokerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "poker_room_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    # Handle incoming WebSocket messages
    ActionCable.server.broadcast("poker_room_#{params[:room_id]}", data)
  end

  def make_action(data)
    # Handle player actions (fold, call, raise, etc.)
    ActionCable.server.broadcast("poker_room_#{params[:room_id]}", {
      action: 'game_update',
      player_id: data['player_id'],
      action_type: data['action_type'],
      amount: data['amount']
    })
  end
end
