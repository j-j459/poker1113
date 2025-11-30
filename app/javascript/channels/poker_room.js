import consumer from "./consumer"

const PokerGame = {
  // Game state
  gameState: {
    players: [],
    communityCards: [],
    pot: 0,
    currentBet: 0,
    dealerPosition: 0,
    currentPlayer: null,
    gameStage: 'waiting', // waiting, preflop, flop, turn, river, showdown
    minRaise: 0,
    currentPlayerIndex: 0
  },

  // DOM Elements
  elements: {
    table: null,
    playerHand: null,
    communityCards: null,
    potDisplay: null,
    actionButtons: null,
    playerList: null
  },

  // Initialize the game
  init() {
    this.cacheElements()
    this.setupEventListeners()
    this.setupWebSocket()
    this.render()
  },

  // Cache DOM elements
  cacheElements() {
    this.elements.table = document.querySelector('.poker-table')
    this.elements.playerHand = document.querySelector('.player-hand')
    this.elements.communityCards = document.querySelector('.community-cards')
    this.elements.potDisplay = document.querySelector('.pot-display')
    this.elements.actionButtons = document.querySelector('.action-buttons')
    this.elements.playerList = document.querySelector('.player-list')
  },

  // Setup event listeners
  setupEventListeners() {
    // Fold button
    document.querySelector('.btn-fold')?.addEventListener('click', () => this.handleAction('fold'))
    
    // Check/Call button
    document.querySelector('.btn-call')?.addEventListener('click', () => {
      this.handleAction('call')
    })
    
    // Raise button
    document.querySelector('.btn-raise')?.addEventListener('click', () => {
      const amount = parseInt(document.querySelector('.raise-amount')?.value) || this.gameState.currentBet
      this.handleAction('raise', amount)
    })
  },

  // Setup WebSocket connection
  setupWebSocket() {
    this.channel = consumer.subscriptions.create(
      { channel: "PokerChannel", room_id: 'main' },
      {
        connected() {
          console.log('Connected to PokerChannel')
        },
        
        disconnected() {
          console.log('Disconnected from PokerChannel')
        },
        
        received: (data) => this.handleGameUpdate(data)
      }
    )
  },

  // Handle player actions
  handleAction(actionType, amount = 0) {
    this.channel.perform('make_action', {
      player_id: this.getCurrentPlayerId(),
      action_type: actionType,
      amount: amount
    })
  },

  // Handle game updates from server
  handleGameUpdate(data) {
    if (data.action === 'game_update') {
      // Update game state based on server data
      this.updateGameState(data)
      this.render()
    }
  },

  // Update game state
  updateGameState(data) {
    // Update game state based on server data
    // This would be expanded based on your game logic
  },

  // Render the game
  render() {
    this.renderCommunityCards()
    this.renderPlayerHand()
    this.renderPot()
    this.renderPlayers()
    this.updateActionButtons()
  },

  // Render community cards
  renderCommunityCards() {
    if (!this.elements.communityCards) return
    
    this.elements.communityCards.innerHTML = this.gameState.communityCards
      .map(card => `<div class="card">${card}</div>`)
      .join('')
  },

  // Render player's hand
  renderPlayerHand() {
    if (!this.elements.playerHand) return
    
    const currentPlayer = this.gameState.players[this.gameState.currentPlayerIndex]
    if (currentPlayer && currentPlayer.cards) {
      this.elements.playerHand.innerHTML = currentPlayer.cards
        .map(card => `<div class="card">${card}</div>`)
        .join('')
    }
  },

  // Render pot
  renderPot() {
    if (this.elements.potDisplay) {
      this.elements.potDisplay.textContent = `Pot: $${this.gameState.pot}`
    }
  },

  // Render player list
  renderPlayers() {
    if (!this.elements.playerList) return
    
    this.elements.playerList.innerHTML = this.gameState.players
      .map((player, index) => {
        const isCurrent = index === this.gameState.currentPlayerIndex
        const isActive = player.isActive
        const isFolded = player.isFolded
        const chips = player.chips || 0
        const currentBet = player.currentBet || 0
        
        return `
          <div class="player ${isCurrent ? 'current' : ''} ${!isActive ? 'inactive' : ''} ${isFolded ? 'folded' : ''}">
            <div class="player-name">${player.name}</div>
            <div class="player-chips">$${chips}</div>
            ${currentBet > 0 ? `<div class="player-bet">Bet: $${currentBet}</div>` : ''}
            ${player.cards && !isFolded ? `
              <div class="player-cards">
                ${player.cards.map(card => `<div class="card">${card}</div>`).join('')}
              </div>
            ` : ''}
          </div>
        `
      })
      .join('')
  },

  // Update action buttons based on game state
  updateActionButtons() {
    if (!this.elements.actionButtons) return
    
    const currentPlayer = this.gameState.players[this.gameState.currentPlayerIndex]
    if (!currentPlayer || !currentPlayer.isActive) {
      this.elements.actionButtons.style.display = 'none'
      return
    }
    
    this.elements.actionButtons.style.display = 'flex'
    
    // Update call/check button
    const callButton = this.elements.actionButtons.querySelector('.btn-call')
    if (callButton) {
      const amountToCall = this.gameState.currentBet - (currentPlayer.currentBet || 0)
      callButton.textContent = amountToCall > 0 ? `Call $${amountToCall}` : 'Check'
      callButton.disabled = amountToCall > (currentPlayer.chips || 0)
    }
    
    // Update raise controls
    const raiseInput = this.elements.actionButtons.querySelector('.raise-amount')
    const raiseButton = this.elements.actionButtons.querySelector('.btn-raise')
    
    if (raiseInput && raiseButton) {
      const minRaise = Math.max(
        this.gameState.minRaise,
        this.gameState.currentBet * 2
      )
      const maxRaise = currentPlayer.chips || 0
      
      raiseInput.min = minRaise
      raiseInput.max = maxRaise
      raiseInput.value = minRaise
      raiseInput.placeholder = `$${minRaise}-$${maxRaise}`
      
      raiseButton.disabled = maxRaise < minRaise
    }
  },

  // Helper to get current player ID (you would replace this with actual auth)
  getCurrentPlayerId() {
    // This would come from your authentication system
    return 'player_' + Math.floor(Math.random() * 1000)
  }
}

// Initialize the game when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  PokerGame.init()
})
