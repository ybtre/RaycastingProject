
#include <stdio.h>
#include <SDL.h>
#include "constants.h"

SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
int isGameRunning = FALSE;

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

}

/////////////////////////////////////////////
int main(){
  isGameRunning = initializeWindow();

  setup();

  // while (isGameRunning) {
    // processInput();
    // update();
    // render();
  // }

  destroyWindow();

  return 0;
}
