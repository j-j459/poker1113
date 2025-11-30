(() => {
  const canvas = document.getElementById('tetris-canvas');
  if (!canvas) return;
  const context = canvas.getContext('2d');
  context.scale(32, 32);

  const COLS = 10;
  const ROWS = 20;
  const COLORS = {
    'I': '#00FFFF',
    'J': '#0000FF',
    'L': '#FFA500',
    'O': '#FFFF00',
    'S': '#00FF00',
    'T': '#800080',
    'Z': '#FF0000',
  };

  function createMatrix(width, height) {
    const matrix = [];
    for (let y = 0; y < height; y += 1) {
      matrix.push(new Array(width).fill(0));
    }
    return matrix;
  }

  function createPiece(type) {
    switch (type) {
      case 'T': return [ [0,1,0], [1,1,1], [0,0,0] ];
      case 'O': return [ [1,1], [1,1] ];
      case 'L': return [ [0,0,1], [1,1,1], [0,0,0] ];
      case 'J': return [ [1,0,0], [1,1,1], [0,0,0] ];
      case 'I': return [ [0,0,0,0], [1,1,1,1], [0,0,0,0], [0,0,0,0] ];
      case 'S': return [ [0,1,1], [1,1,0], [0,0,0] ];
      case 'Z': return [ [1,1,0], [0,1,1], [0,0,0] ];
      default: return [ [1] ];
    }
  }

  function drawCell(x, y, color) {
    context.fillStyle = color;
    context.fillRect(x, y, 1, 1);
    context.strokeStyle = '#111';
    context.lineWidth = 0.05;
    context.strokeRect(x, y, 1, 1);
  }

  function drawMatrix(matrix, offset, color) {
    matrix.forEach((row, y) => {
      row.forEach((value, x) => {
        if (value) {
          drawCell(x + offset.x, y + offset.y, color || '#999');
        }
      });
    });
  }

  function merge(arena, player) {
    player.matrix.forEach((row, y) => {
      row.forEach((value, x) => {
        if (value !== 0) {
          arena[y + player.pos.y][x + player.pos.x] = player.type;
        }
      });
    });
  }

  function collide(arena, player) {
    const m = player.matrix;
    const o = player.pos;
    for (let y = 0; y < m.length; y += 1) {
      for (let x = 0; x < m[y].length; x += 1) {
        if (m[y][x] !== 0 && (
          arena[y + o.y] &&
          arena[y + o.y][x + o.x] !== 0
        )) {
          return true;
        }
      }
    }
    return false;
  }

  function rotate(matrix, dir) {
    for (let y = 0; y < matrix.length; y += 1) {
      for (let x = 0; x < y; x += 1) {
        [matrix[x][y], matrix[y][x]] = [matrix[y][x], matrix[x][y]];
      }
    }
    if (dir > 0) {
      matrix.forEach(row => row.reverse());
    } else {
      matrix.reverse();
    }
  }

  function arenaSweep() {
    let rowCount = 1;
    outer: for (let y = arena.length - 1; y >= 0; y -= 1) {
      for (let x = 0; x < arena[y].length; x += 1) {
        if (arena[y][x] === 0) {
          continue outer;
        }
      }
      const row = arena.splice(y, 1)[0].fill(0);
      arena.unshift(row);
      y += 1;
      player.score += rowCount * 10;
      rowCount *= 2;
      updateScore();
    }
  }

  function draw() {
    context.fillStyle = '#000';
    context.fillRect(0, 0, canvas.width, canvas.height);
    drawMatrix(arena.map(row => row.map(c => c ? 1 : 0)), {x:0, y:0});
    drawMatrix(player.matrix, player.pos, COLORS[player.type]);
    // Draw settled blocks with colors
    for (let y = 0; y < arena.length; y += 1) {
      for (let x = 0; x < arena[y].length; x += 1) {
        const t = arena[y][x];
        if (t) drawCell(x, y, COLORS[t]);
      }
    }
  }

  function playerDrop() {
    player.pos.y += 1;
    if (collide(arena, player)) {
      player.pos.y -= 1;
      merge(arena, player);
      playerReset();
      arenaSweep();
    }
    dropCounter = 0;
  }

  function playerMove(dir) {
    player.pos.x += dir;
    if (collide(arena, player)) {
      player.pos.x -= dir;
    }
  }

  function playerReset() {
    const pieces = 'TJLOSZI';
    player.type = pieces[(pieces.length * Math.random()) | 0];
    player.matrix = createPiece(player.type);
    player.pos.y = 0;
    player.pos.x = ((COLS / 2) | 0) - ((player.matrix[0].length / 2) | 0);
    if (collide(arena, player)) {
      arena.forEach(row => row.fill(0));
      player.score = 0;
      updateScore();
    }
  }

  function playerRotate(dir) {
    const posX = player.pos.x;
    let offset = 1;
    rotate(player.matrix, dir);
    while (collide(arena, player)) {
      player.pos.x += offset;
      offset = -(offset + (offset > 0 ? 1 : -1));
      if (offset > player.matrix[0].length) {
        rotate(player.matrix, -dir);
        player.pos.x = posX;
        return;
      }
    }
  }

  let dropCounter = 0;
  let dropInterval = 800; // ms
  let lastTime = 0;

  function update(time = 0) {
    const deltaTime = time - lastTime;
    lastTime = time;
    dropCounter += deltaTime;
    if (dropCounter > dropInterval) {
      playerDrop();
    }
    draw();
    requestAnimationFrame(update);
  }

  function updateScore() {
    if (!scoreEl) return;
    scoreEl.textContent = `Score: ${player.score}`;
  }

  document.addEventListener('keydown', event => {
    if (event.key === 'ArrowLeft') {
      playerMove(-1);
    } else if (event.key === 'ArrowRight') {
      playerMove(1);
    } else if (event.key === 'ArrowDown') {
      playerDrop();
    } else if (event.key === 'ArrowUp' || event.key === ' ') {
      playerRotate(1);
    }
  });

  const arena = createMatrix(COLS, ROWS);
  const player = {
    pos: { x: 0, y: 0 },
    matrix: null,
    type: 'T',
    score: 0,
  };
  const scoreEl = (() => {
    const el = document.createElement('div');
    el.id = 'tetris-score';
    el.style.marginTop = '8px';
    el.style.color = '#333';
    canvas.parentElement.appendChild(el);
    return el;
  })();

  playerReset();
  updateScore();
  update();
})();




