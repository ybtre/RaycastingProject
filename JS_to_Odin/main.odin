package raycaster

import "core:fmt"
import "core:mem"
import "core:math"
import sdl "vendor:sdl2"


////////////////////////////////////////////////////////
// CONSTANTS
////////////////////////////////////////////////////////
PI                   :: 3.14159265
TWO_PI               :: 6.28318530

TILE_SIZE            :: 64
MAP_NUM_ROWS         :: 13
MAP_NUM_COLS         :: 20

MINIMAP_SCALE_FACTOR :: 1.0

WINDOW_WIDHT         :: (MAP_NUM_COLS * TILE_SIZE)
WINDOW_HEIGHT        :: (MAP_NUM_ROWS * TILE_SIZE)

FOV_ANGLE            :: (60 * (PI / 180))

NUM_RAYS             :: WINDOW_WIDHT

FPS                  :: 60
FRAME_TIME_LENGTH_MS :: (1000 / FPS)


////////////////////////////////////////////////////////
// STRUCTS
////////////////////////////////////////////////////////
Player :: struct {
  x         : f32,
  y         : f32,
  width     : f32,
  height    : f32,
  turnDir   : i32, // -1 for left, +1 for right
  walkDir   : i32, // -1 for back, +1 for front
  rotAngle  : f32,
  walkSpeed : f32,
  turnSpeed : f32,
}
player : Player

grid := [MAP_NUM_ROWS][MAP_NUM_COLS]i32 {
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
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

////////////////////////////////////////////////////////
// VARIABLES
////////////////////////////////////////////////////////
is_game_running : = false
window          : ^sdl.Window
renderer        : ^sdl.Renderer
ticksLastFrame  : u32

////////////////////////////////////////////////////////
// FUNCTIONS
////////////////////////////////////////////////////////
initialize_window ::proc() -> bool {
  if (sdl.Init(sdl.INIT_EVERYTHING) != 0 ) {
    fmt.println("Error initializing SDL - ", sdl.GetErrorString())
    return false
  }

  window = sdl.CreateWindow(
    "Raycaster in Odin",
    sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED,
    WINDOW_WIDHT, WINDOW_HEIGHT,
    sdl.WINDOW_BORDERLESS | sdl.WINDOW_MOUSE_FOCUS)
  if window == nil{
    fmt.println("Error creating SDL Window - ", sdl.GetErrorString())
    return false
  }

  renderer = sdl.CreateRenderer(window, -1, sdl.RENDERER_SOFTWARE)
  if renderer == nil {
    fmt.println("Error creating SDL Renderer - ", sdl.GetErrorString())
    return false
  }

  sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.BLEND)

  fmt.println("Successfuly initialized Window and Renderer!")
  return true
}

////////////////////////////////////////////////////////
setup ::proc() {
  player.x = WINDOW_WIDHT / 2
  player.y = WINDOW_HEIGHT / 2
  player.width = 5
  player.height = 5
  player.turnDir = 0
  player.walkDir = 0
  player.rotAngle = PI / 2
  player.walkSpeed = 50
  player.turnSpeed = 90 * ( PI / 180 )
}

////////////////////////////////////////////////////////
movePlayer :: proc(dt : f32) {
  player.rotAngle += cast(f32)player.turnDir * player.turnSpeed * dt

  moveStep := cast(f32)player.walkDir * player.walkSpeed * dt

  newPlayerX := player.x + sdl.cosf(player.rotAngle) * moveStep
  newPlayerY := player.y + sdl.sinf(player.rotAngle) * moveStep

  player.x = newPlayerX
  player.y = newPlayerY
}


////////////////////////////////////////////////////////
renderPlayer :: proc() {
  sdl.SetRenderDrawColor(renderer, 245, 245, 0, 255)
  playerRect : sdl.Rect = {
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.x),
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.y),
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.width),
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.height),
  }
  sdl.RenderFillRect(renderer, &playerRect)

  sdl.RenderDrawLine(
    renderer,
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.x),
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.y),
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.x + sdl.cosf(player.rotAngle) * 40),
    i32(MINIMAP_SCALE_FACTOR * cast(f32)player.y + sdl.sinf(player.rotAngle) * 40),
  )
}

////////////////////////////////////////////////////////
renderMap :: proc() {
  for i:i32 = 0; i < MAP_NUM_ROWS; i+=1 {
    for j:i32 = 0; j < MAP_NUM_COLS; j+=1 {
      tileX := j * TILE_SIZE
      tileY := i * TILE_SIZE
      tileColor : u8 = grid[i][j] != 0 ? 225 : 0

      sdl.SetRenderDrawColor(renderer, tileColor, tileColor, tileColor, 255)
      /*////////////////////////////////////////////////////////
      the problem was caused due to the order I was manually casting
      stuff and the order C automatically casts.
      I have to cast the ints to floats, multiply them 
      and only then cast the result back to ints so as not to get a 0 value.
      *///////////////////////////////////////////////////////// 
      mapTileRect : sdl.Rect = {
        i32(cast(f32)tileX * MINIMAP_SCALE_FACTOR),
        i32(cast(f32)tileY * MINIMAP_SCALE_FACTOR),
        i32(sdl.floorf(cast(f32)TILE_SIZE * MINIMAP_SCALE_FACTOR)),
        i32(sdl.floorf(cast(f32)TILE_SIZE * MINIMAP_SCALE_FACTOR)),
      }
      sdl.RenderFillRect(renderer, &mapTileRect)
    }
  }
}

////////////////////////////////////////////////////////
process_input ::proc() {
  event : sdl.Event

  for sdl.PollEvent(&event) {
    #partial switch event.type {
    case sdl.EventType.QUIT:
      {
        is_game_running = false
      }
    case sdl.EventType.KEYDOWN:
      {
        if event.key.keysym.sym == sdl.Keycode.ESCAPE {
          is_game_running = false
        }
        if event.key.keysym.sym == sdl.Keycode.UP {
          player.walkDir = +1
        }
        if event.key.keysym.sym == sdl.Keycode.DOWN {
          player.walkDir = -1
        }
        if event.key.keysym.sym == sdl.Keycode.LEFT {
          player.turnDir = -1
        }
        if event.key.keysym.sym == sdl.Keycode.RIGHT {
          player.turnDir = +1
        }
      }
    case sdl.EventType.KEYUP:
      {
        if event.key.keysym.sym == sdl.Keycode.UP {
          player.walkDir = 0 
        }
        if event.key.keysym.sym == sdl.Keycode.DOWN {
          player.walkDir = 0
        }
        if event.key.keysym.sym == sdl.Keycode.LEFT {
          player.turnDir = 0
        }
        if event.key.keysym.sym == sdl.Keycode.RIGHT {
          player.turnDir = 0
        }
      }
    }
  }
}

////////////////////////////////////////////////////////
update :: proc() {
  timeToWait : u32 = FRAME_TIME_LENGTH_MS - (sdl.GetTicks() - ticksLastFrame)

  if timeToWait > 0 && timeToWait <= FRAME_TIME_LENGTH_MS {
    sdl.Delay(timeToWait)
  }

  dt : f32 = f32(sdl.GetTicks() - ticksLastFrame) / 1000.0
  ticksLastFrame = sdl.GetTicks()

  //Update Game Objects Area
  {
    movePlayer(dt)
  }
}

////////////////////////////////////////////////////////
render :: proc() {
  sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255)
  sdl.RenderClear(renderer)

  //Render Game Objects Area
  {
    renderMap()
    renderPlayer()
  }

  sdl.RenderPresent(renderer)
}

destroy_window :: proc() {
  sdl.DestroyRenderer(renderer)
  sdl.DestroyWindow(window)
  sdl.Quit()
}

////////////////////////////////////////////////////////
// MAIN
////////////////////////////////////////////////////////
main :: proc()
{
////////////////////////////////////////////////////////
// TRACKING ALLOCATOR
////////////////////////////////////////////////////////
  track: mem.Tracking_Allocator
  mem.tracking_allocator_init(&track, context.allocator)
  defer mem.tracking_allocator_destroy(&track)

  context.allocator = mem.tracking_allocator(&track)

  defer {
    for _, leak in track.allocation_map {
      fmt.printf("%v leaked %m\n", leak.location, leak.size)
    }
    for bad_free in track.bad_free_array {
      fmt.printf(
        "%v allocation %p was freed badly\n",
        bad_free.location,
        bad_free.memory,
      )
    }
  }
////////////////////////////////////////////////////////

  is_game_running = initialize_window()

  setup()

  for is_game_running {
    process_input()
    update()
    render()
  }

  destroy_window()

}
