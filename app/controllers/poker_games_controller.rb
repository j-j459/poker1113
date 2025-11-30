class PokerGamesController < ApplicationController
  before_action :set_game_modes, only: [:new, :create]
  
  def new
    @game_session = GameSession.new
  end
  
  def create
    game_params = params.require(:game_session).permit(:game_mode)
    
    # ゲームモードに応じた設定
    case game_params[:game_mode]
    when 'texas_holdem'
      small_blind = 10
      big_blind = 20
      starting_chips = 1000
    when 'omaha'
      small_blind = 25
      big_blind = 50
      starting_chips = 2000
    when 'tournament'
      small_blind = 50
      big_blind = 100
      starting_chips = 5000
    else
      # デフォルト値
      small_blind = 10
      big_blind = 20
      starting_chips = 1000
    end
    
    @game_session = GameSession.create!(
      status: 'waiting',
      pot: 0,
      current_bet: 0,
      dealer_position: 0,
      small_blind: small_blind,
      big_blind: big_blind,
      game_phase: 'preflop',
      game_mode: game_params[:game_mode] || 'texas_holdem',
      starting_chips: starting_chips
    )
    
    @game_session.initialize_game
    redirect_to poker_game_path(@game_session)
  end
  
  private
  
  def set_game_modes
    @game_modes = [
      { id: 'texas_holdem', name: 'テキサスホールデム', description: '2枚のホールカードと5枚のコミュニティカードでプレイ', icon: '♠️' },
      { id: 'omaha', name: 'オマハ', description: '4枚のホールカードから2枚、コミュニティカードから3枚を選択', icon: '♥️' },
      { id: 'tournament', name: 'トーナメント', description: '最後の1人になるまで戦い抜く', icon: '♦️' }
    ]
  end
  
  def show
    @game_session = GameSession.find(params[:id])
    @players = @game_session.players.order(:position)
    @current_player = @players.find_by(position: @game_session.current_player_position)
    @user_player = @players.find_by(player_type: 'human')
    @community_cards = @game_session.community_cards_array
    
    # ゲームが終了している場合は結果を表示
    if @game_session.status == 'finished'
      @winner = determine_winner
    end
  end
  
  def action
    @game_session = GameSession.find(params[:id])
    @player = @game_session.players.find_by(player_type: 'human')
    
    return redirect_to poker_game_path(@game_session), alert: 'ゲームが終了しています' if @game_session.status == 'finished'
    return redirect_to poker_game_path(@game_session), alert: 'あなたのターンではありません' unless @player.position == @game_session.current_player_position
    
    action_type = params[:action_type]
    amount = params[:amount].to_i
    
    case action_type
    when 'fold'
      @player.fold
    when 'check'
      # チェック（ベットが0の場合のみ）
      unless @game_session.current_bet == @player.current_bet
        redirect_to poker_game_path(@game_session), alert: 'チェックできません'
        return
      end
    when 'call'
      call_amount = @game_session.current_bet - @player.current_bet
      if call_amount > 0 && @player.chips >= call_amount
        @player.bet(call_amount)
      elsif call_amount > 0
        redirect_to poker_game_path(@game_session), alert: 'チップが不足しています'
        return
      end
    when 'bet', 'raise'
      if amount < @game_session.big_blind
        redirect_to poker_game_path(@game_session), alert: "最小ベット額は#{@game_session.big_blind}です"
        return
      end
      if amount > @player.chips
        redirect_to poker_game_path(@game_session), alert: 'チップが不足しています'
        return
      end
      @player.bet(amount)
      @game_session.update(current_bet: @player.current_bet)
    when 'all_in'
      @player.bet(@player.chips)
      @game_session.update(current_bet: @player.current_bet) if @player.current_bet > @game_session.current_bet
    end
    
    # アクションを記録
    @game_session.game_actions.create!(
      player: @player,
      action_type: action_type,
      amount: amount,
      game_phase: @game_session.game_phase,
      round_number: @game_session.round_number
    )
    
    # ポットを更新
    @game_session.update(pot: @game_session.players.sum(:total_bet))
    
    # 次のプレイヤーへ
    next_player_position = (@game_session.current_player_position + 1) % @game_session.players.count
    @game_session.update(current_player_position: next_player_position)
    
    # AIのターン
    process_ai_turns
    
    # ゲームフェーズの進行をチェック
    check_and_advance_phase
    
    redirect_to poker_game_path(@game_session)
  end
  
  def determine_winner
    # 簡易的な勝者判定（実際の役判定は後で実装）
    active_players = @game_session.players.where(is_folded: false)
    active_players.order(chips: :desc).first
  end
  
  def check_and_advance_phase
    # 全員が同じベット額になったら次のフェーズへ
    active_players = @game_session.players.where(is_folded: false)
    return if active_players.count <= 1
    
    all_same_bet = active_players.pluck(:current_bet).uniq.length == 1
    
    if all_same_bet
      case @game_session.game_phase
      when 'preflop'
        @game_session.deal_flop
        reset_bets
      when 'flop'
        @game_session.deal_turn
        reset_bets
      when 'turn'
        @game_session.deal_river
        reset_bets
      when 'river'
        # ショーダウン
        @game_session.update(game_phase: 'showdown', status: 'finished')
        distribute_pot
      end
    end
  end
  
  def reset_bets
    @game_session.players.update_all(current_bet: 0)
    @game_session.update(current_bet: 0, current_player_position: (@game_session.dealer_position + 1) % @game_session.players.count)
  end
  
  def distribute_pot
    # 簡易的なポット配布（実際の役判定は後で実装）
    winner = determine_winner
    if winner
      winner.update(chips: winner.chips + @game_session.pot)
      @game_session.update(pot: 0)
    end
  end
  
  private
  
  def process_ai_turns
    loop do
      current_player = @game_session.players.find_by(position: @game_session.current_player_position)
      break if current_player.human? || current_player.is_folded
      
      ai_action = decide_ai_action(current_player)
      
      case ai_action[:type]
      when 'fold'
        current_player.fold
      when 'check'
        # チェック
      when 'call'
        call_amount = @game_session.current_bet - current_player.current_bet
        current_player.bet(call_amount) if call_amount > 0
      when 'bet', 'raise'
        bet_amount = ai_action[:amount]
        current_player.bet(bet_amount)
        @game_session.update(current_bet: current_player.current_bet) if current_player.current_bet > @game_session.current_bet
      end
      
      @game_session.game_actions.create!(
        player: current_player,
        action_type: ai_action[:type],
        amount: ai_action[:amount] || 0,
        game_phase: @game_session.game_phase,
        round_number: @game_session.round_number
      )
      
      # 次のプレイヤーへ
      next_player_position = (@game_session.current_player_position + 1) % @game_session.players.count
      @game_session.update(current_player_position: next_player_position)
      
      # 人間のターンに戻ったら終了
      break if @game_session.players.find_by(position: @game_session.current_player_position).human?
    end
    
    @game_session.update(pot: @game_session.players.sum(:total_bet))
  end
  
  def decide_ai_action(player)
    # シンプルなAIロジック
    hand_strength = calculate_hand_strength(player)
    current_bet_to_call = @game_session.current_bet - player.current_bet
    
    if hand_strength < 0.3 && current_bet_to_call > player.chips * 0.2
      { type: 'fold', amount: 0 }
    elsif hand_strength > 0.7 && current_bet_to_call == 0
      { type: 'bet', amount: [@game_session.big_blind * 2, player.chips / 4].min }
    elsif hand_strength > 0.5 && current_bet_to_call <= player.chips * 0.1
      { type: 'call', amount: current_bet_to_call }
    elsif current_bet_to_call == 0
      { type: 'check', amount: 0 }
    elsif hand_strength < 0.4
      { type: 'fold', amount: 0 }
    else
      { type: 'call', amount: current_bet_to_call }
    end
  end
  
  def calculate_hand_strength(player)
    # 簡易的な手の強さ計算（0.0-1.0）
    cards = player.hand_cards_array
    ranks = cards.map { |c| c['rank'] }
    
    # ペアがあるかチェック
    if ranks.uniq.length < ranks.length
      return 0.6
    end
    
    # ハイカードの強さ
    high_cards = ['A', 'K', 'Q', 'J', '10'].count { |r| ranks.include?(r) }
    high_cards * 0.15
  end
end

