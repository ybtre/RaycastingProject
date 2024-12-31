
#include <stdio.h>
#include <SDL.h>
#include "constants.h"

const int map[MAP_NUM_ROWS][MAP_NUM_COLS] = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ,1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
};

struct Player {
  float x;
  float y;
  float width;
  float height;
  int turnDir; // -1 for left, +1 for right
  int walkDir; // -1 for back, +1 for front
  float rotAngle;
  float walkSpeed;
  float turnSpeed;
} player;

SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
int isGameRunning = FALSE;

int ticksLastFrame = 0;

/////////////////////////////////////////////
int initializeWindow() {
  if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
    fprintf(stderr, "Error initializing SDL.\n");
    return FALSE;
  };

  window = SDL_CreateWindow(
    "Raycaster in C",
    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    WINDOW_WIDTH, WINDOW_HEIGHT,
    SDL_WINDOW_BORDERLESS | SDL_WINDOW_MOUSE_FOCUS
  );

  if (!window) {
    fprintf(stderr, "Error creating SDL Window.\n");
    return FALSE;
  }

  renderer = SDL_CreateRenderer(
    window,
    -1,
    SDL_RENDERER_SOFTWARE
  );
  if (!renderer) {
    fprintf(stderr, "Error creating SDL Renderer.\n");
    return FALSE;
  }

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);

  puts("Successfuly Initialized Window and Renderer!\n");

  return TRUE;
}

/////////////////////////////////////////////
void destroyWindow() {
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();
}

/////////////////////////////////////////////
void setup() {
  //initialize and setup game objects
  player.x         = WINDOW_WIDTH / 2;
  player.y         = WINDOW_HEIGHT / 2;
  player.width     = 5;
  player.height    = 5;
  player.turnDir   = 0;
  player.walkDir   = 0;
  player.rotAngle  = PI / 2;
  player.walkSpeed = 100;
  player.turnSpeed = 45 * (PI / 180);
}

/////////////////////////////////////////////
void renderMap(){
  for (int i = 0; i < MAP_NUM_ROWS; i++) {
    for(int j = 0; j < MAP_NUM_COLS; j++) {
      int tileX = j * TILE_SIZE;
      int tileY = i * TILE_SIZE;
      int tileColor = map[i][j] != 0 ? 235 : 0;

      SDL_SetRenderDrawColor(renderer, tileColor, tileColor, tileColor, 255);
      SDL_Rect mapTileRect = {
        tileX * MINIMAP_SCALE_FACTOR,
        tileY * MINIMAP_SCALE_FACTOR,
        TILE_SIZE * MINIMAP_SCALE_FACTOR,
        TILE_SIZE * MINIMAP_SCALE_FACTOR
      };
      SDL_RenderFillRect(renderer, &mapTileRect);
    }
  }
}

/////////////////////////////////////////////
void processInput() {
  SDL_Event event;
  SDL_PollEvent(&event);

  switch (event.type) {
    case SDL_QUIT: {
      isGameRunning = FALSE;
      break;
    }
    case SDL_KEYDOWN: {
      if (event.key.keysym.sym == SDLK_ESCAPE) {
        isGameRunning = FALSE;
      }
      break;
    }
  }
}

/////////////////////////////////////////////
void update() {
  int timeToWait = FRAME_TIME_LENGTH_MS - (SDL_GetTicks() - ticksLastFrame);

  if(timeToWait > 0 && timeToWait <= FRAME_TIME_LENGTH_MS) {
    SDL_Delay(timeToWait);
  }

  float dt = (SDL_GetTicks() - ticksLastFrame) / 1000.f;
  ticksLastFrame = SDL_GetTicks();

  //Update Game Objects Area
  {
  }
}

/////////////////////////////////////////////
void render() {
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
  SDL_RenderClear(renderer);

  //Render Game Objects Area
  {
    renderMap();
    // renderRays();
    // renderPlayer();
  }

  SDL_RenderPresent(renderer);
}

/////////////////////////////////////////////
int main(){
  isGameRunning = initializeWindow();

  setup();

  while (isGameRunning) {
    processInput();
    update();
    render();
  }

  destroyWindow();

  return 0;
}
