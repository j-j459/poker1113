class GameSession < ApplicationRecord
  belongs_to :user, optional: true
  has_many :players, dependent: :destroy
  has_many :game_actions, dependent: :destroy

  enum status: { waiting: 'waiting', active: 'active', finished: 'finished' }
  enum game_phase: { preflop: 'preflop', flop: 'flop', turn: 'turn', river: 'river', showdown: 'showdown' }
  enum game_mode: { texas_holdem: 'texas_holdem', omaha: 'omaha', tournament: 'tournament' }, _default: 'texas_holdem'
  
  attribute :starting_chips, :integer, default: 1000

  def initialize_game
    # プレイヤーを初期化
    create_players
    
    # デッキをシャッフル
    deck = create_deck.shuffle
    
    # 各プレイヤーに2枚ずつカードを配る
    players.each_with_index do |player, index|
      player.update(hand_cards: [deck.pop, deck.pop].to_json)
    end
    
    # 残りのデッキとコミュニティカードを保存
    update(
      deck: deck.to_json, 
      community_cards: [].to_json,
      status: 'active', 
      game_phase: 'preflop'
    )
    
    # ブラインドを設定
    set_blinds
  end

  def create_players
    # ユーザープレイヤー
    players.create!(
      player_type: 'human',
      name: user.name || user.email,
      chips: 1000,
      position: 0,
      is_active: true
    )
    
    # AIプレイヤー3名
    ai_names = ['AIプレイヤー1', 'AIプレイヤー2', 'AIプレイヤー3']
    ai_names.each_with_index do |name, index|
      players.create!(
        player_type: 'ai',
        name: name,
        chips: 1000,
        position: index + 1,
        is_active: true
      )
    end
  end

  def create_deck
    suits = ['♠', '♥', '♦', '♣']
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    deck = []
    suits.each do |suit|
      ranks.each do |rank|
        deck << { suit: suit, rank: rank }
      end
    end
    deck
  end

  def set_blinds
    dealer_pos = dealer_position % players.count
    sb_pos = (dealer_pos + 1) % players.count
    bb_pos = (dealer_pos + 2) % players.count
    
    sb_player = players.find_by(position: sb_pos)
    bb_player = players.find_by(position: bb_pos)
    
    sb_player.update(chips: sb_player.chips - small_blind, current_bet: small_blind, total_bet: small_blind)
    bb_player.update(chips: bb_player.chips - big_blind, current_bet: big_blind, total_bet: big_blind)
    
    update(pot: small_blind + big_blind, current_bet: big_blind, current_player_position: (bb_pos + 1) % players.count)
  end

  def community_cards_array
    JSON.parse(community_cards || '[]')
  end

  def deck_array
    JSON.parse(deck || '[]')
  end

  def deal_flop
    deck = deck_array
    flop_cards = [deck.pop, deck.pop, deck.pop]
    update(
      deck: deck.to_json,
      community_cards: flop_cards.to_json,
      game_phase: 'flop'
    )
    flop_cards
  end

  def deal_turn
    deck = deck_array
    turn_card = deck.pop
    current_community = community_cards_array
    update(
      deck: deck.to_json,
      community_cards: (current_community + [turn_card]).to_json,
      game_phase: 'turn'
    )
    turn_card
  end

  def deal_river
    deck = deck_array
    river_card = deck.pop
    current_community = community_cards_array
    update(
      deck: deck.to_json,
      community_cards: (current_community + [river_card]).to_json,
      game_phase: 'river'
    )
    river_card
  end
end
