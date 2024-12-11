package main

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:math"

import rl "vendor:raylib"

Sheet :: struct {
	frames: [dynamic]SheetFrame,
}

SheetFrame :: struct {
	frame:            SheetRect,
	rotated:          bool,
	trimmed:          bool,
	spriteSourceSize: SheetRect,
	sourceSize:       SheetSize,
	duration:         int,
}

SheetSize :: struct {
	w, h: int,
}

SheetRect :: struct {
	x, y, w, h: int,
}

ivec2 :: [2]i32

main :: proc() {
	fmt.println("Hello, World!")
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(960, 540, "Gattobono - Lemonade")
	// rl.SetWindowState({.WINDOW_RESIZABLE, .WINDOW_MAXIMIZED})
	// rl.SetWindowMinSize(960, 540)
	// rl.SetWindowSize(100, 100)
	// rl.WIndow

	rl.SetTargetFPS(60)

	sprite_sheet := rl.LoadTexture("resources/neighborhood.png")

	data, success := os.read_entire_file_from_filename("resources/neighborhood.json")
	if !success {
		fmt.eprintln("Failed to load sprite sheet json file")
		return
	}
	defer delete(data)

	sheet: Sheet
	if err := json.unmarshal(data, &sheet); err != nil {
		fmt.eprintln("Failed to unmarshal sprite sheet json file", err)
		return
	}

	fmt.println(sheet)

	render_size := ivec2{rl.GetRenderWidth(), rl.GetRenderHeight()}
    render_scale := math.min(render_size.x / 320, render_size.y / 180)
    render_offset := (render_size - {320, 180} * render_scale) / 2

	for !rl.WindowShouldClose() {
        if rl.IsWindowResized() {
	        render_size = ivec2{rl.GetRenderWidth(), rl.GetRenderHeight()}
            render_scale = math.min(render_size.x / 320, render_size.y / 180)
            render_offset = (render_size - {320, 180} * render_scale) / 2
        }
		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)

		for v in sheet.frames {
			// v.frame
			rl.DrawTexturePro(
				sprite_sheet,
				 {
					x = f32(v.frame.x),
					y = f32(v.frame.y),
					width = f32(v.frame.w),
					height = f32(v.frame.h),
				},
				 {
					x = f32(int(render_offset.x) + v.spriteSourceSize.x * int(render_scale)),
					y = f32(int(render_offset.y) + v.spriteSourceSize.y * int(render_scale)),
					width = f32(v.frame.w * int(render_scale)),
					height = f32(v.frame.h * int(render_scale)),
				},
				{0, 0},
				0,
				rl.WHITE,
			)
		}

		rl.DrawText("Hello, World!", 960 / 2, 540 / 2, 20, rl.BLACK)

		rl.EndDrawing()
	}
}
