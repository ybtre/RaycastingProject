const TILE_SIZE = 32;
const MAP_NUM_ROWS = 11;
const MAP_NUM_COLS = 15;

const WINDOW_WIDTH = MAP_NUM_COLS * TILE_SIZE;
const WINDOW_HEIGHT = MAP_NUM_ROWS * TILE_SIZE;

class Map {
  constructor() {
    this.grid = [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
      [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ];
  }

  hasWallAt(x, y) {
    if (x < 0 || x > WINDOW_WIDTH || y < 0 || y > WINDOW_HEIGHT) {
      return true;
    }

    var gridX = Math.floor(x / TILE_SIZE);
    var gridY = Math.floor(y / TILE_SIZE);

    return (this.grid[gridX][gridY] === 1) ? true : false;
  }

  render() {
    for (var i = 0; i < MAP_NUM_ROWS; i++) {
      for (var j = 0; j < MAP_NUM_COLS; j++) {
        var tileX = j * TILE_SIZE;
        var tileY = i * TILE_SIZE;
        var tileColor = this.grid[i][j] == 1 ? "#222" : "#fff";
        stroke("#222");
        fill(tileColor);
        rect(tileX, tileY, TILE_SIZE, TILE_SIZE);
      }
    }
  }
}

class Player {
  constructor() {
    this.x = WINDOW_WIDTH / 2;
    this.y = WINDOW_HEIGHT / 2;
    this.radius = 5;
    this.turnDir = 0; // -1 if left, +1 if right
    this.walkDir = 0; // -1 if back, +1 if forward
    this.rotAngle = Math.PI / 2;
    this.moveSpeed = 2.0;
    this.rotSpeed = 4 * (Math.PI / 180);
  }

  update() {
    this.rotAngle += this.turnDir * this.rotSpeed;

    var moveStep = this.walkDir * this.moveSpeed;
    var newX = this.x + Math.cos(this.rotAngle) * moveStep;
    var newY = this.y + Math.sin(this.rotAngle) * moveStep;

    //only set new player position if it is not colliding with walls
    if (!grid.hasWallAt(newX, newY)) {
      this.x = newX;
      this.y = newY;
    }
  }

  render() {
    noStroke();
    fill("red");
    circle(this.x, this.y, this.radius);
    stroke("red");
    line(
      this.x,
      this.y,
      this.x + Math.cos(this.rotAngle) * 30,
      this.y + Math.sin(this.rotAngle) * 30,
    );
  }
}

var grid = new Map();
var player = new Player();

function keyPressed() {
  if (keyCode == UP_ARROW) {
    player.walkDir = +1;
  } else if (keyCode == DOWN_ARROW) {
    player.walkDir = -1;
  } else if (keyCode == RIGHT_ARROW) {
    player.turnDir = +1;
  } else if (keyCode == LEFT_ARROW) {
    player.turnDir = -1;
  }
}

function keyReleased() {
  if (keyCode == UP_ARROW) {
    player.walkDir = 0;
  } else if (keyCode == DOWN_ARROW) {
    player.walkDir = 0;
  } else if (keyCode == RIGHT_ARROW) {
    player.turnDir = 0;
  } else if (keyCode == LEFT_ARROW) {
    player.turnDir = 0;
  }
}

function setup() {
  createCanvas(WINDOW_WIDTH, WINDOW_HEIGHT);
  frameRate(60);
}

function update() {
  player.update();
}

function draw() {
  console.log(frameRate());
  update();

  grid.render();
  player.render();
}
