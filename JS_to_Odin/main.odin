package raycaster

import "core:fmt"
import "core:mem"
import "core:math"
import sdl "vendor:sdl2"


////////////////////////////////////////////////////////
// CONSTANTS
////////////////////////////////////////////////////////
SCREEN_WIDHT :: 320
SCREEN_HEIGHT :: 160


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


}
