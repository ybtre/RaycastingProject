package raycaster

import "core:fmt"
import "core:mem"
import "core:math"
import sdl "vendor:sdl2"


////////////////////////////////////////////////////////
// CONSTANTS
////////////////////////////////////////////////////////
WINDOW_WIDHT  :: 320
WINDOW_HEIGHT :: 160

////////////////////////////////////////////////////////
// VARIABLES
////////////////////////////////////////////////////////
is_game_running : = false
window          : ^sdl.Window
renderer        : ^sdl.Renderer

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
    sdl.WINDOW_BORDERLESS | sdl.WINDOW_MOUSE_FOCUS
  )
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

}

////////////////////////////////////////////////////////
process_input ::proc() {

}

////////////////////////////////////////////////////////
update :: proc() {

}

////////////////////////////////////////////////////////
render :: proc() {

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
