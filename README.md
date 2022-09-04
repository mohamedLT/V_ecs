V ecs is an Entity component System library for V that have a simplistic yet powerful design 
# What is ecs :
ECS is a programming pattern that is mostly used in games 
  - E: Entities which are in most cases just an id 
  - C: Component and thay are simple structs 
  - S: Systems and they are functions that use or change compenents 
# Usage :
V ecs have a very simple desing you basically have to create a struct and a function that use the data in that struct 
Here is an example 

```

import gg
import gx
import mohamedLT.vecs as ecs

const (
	win_width  = 600
	win_height = 300
)

struct App {
mut:
	gg    &gg.Context
	image gg.Image
  // the world object is what makes everthing work 
	world ecs.World
}

// a Position Component 
struct Pos {
	ecs.Comp
mut:
	x f32
	y f32
}
// a Color Component
struct Color {
	ecs.Comp
	color gx.Color
}
// A Resource Can be anything from pictures to simple data 
struct Number{
	ecs.Resource
	val int
}

fn main() {
	mut app := &App{
		gg: 0
	}
  // add entity takes a list of the component you need in it 
	app.world.add_entity([Pos{x:0,y:20},Color{color:gx.gray}])
  // add system takes a function name and a list of compenets that must be in an entity to apply this system to 
	app.world.add_system(app.draw,[Pos{},Color{}])
  // same as above but just gives a mut entity 
	app.world.add_system_mut(frame,[Pos{},Color{}])
  // add resource to the world 
	app.world.add_resource(Number{val:2,name:'numb'})
	app.gg = gg.new_context(
		bg_color: gx.white
		width: win_width
		height: win_height
		create_window: true
		window_title: 'Rectangles'
		frame_fn: update
		user_data:app
	)
	app.gg.run()
}

fn update(mut app App){
  // world.step needs to be called every frame or whenever you want to update the world 
	app.world.step()
}
// any system needs to accept a mut entity or an unmut one and a ResourceManger 
fn(app &App) draw(e ecs.Entity,mut r ecs.ResourceManger){
	app.gg.begin()
  // Entity.get_comp return the component of that entity
	p := e.get_comp<Pos>()or {panic("")}
	c:= e.get_comp<Color>()or {panic("")}
  // ResourceManger.get_resource takes a resource name and returns it 
	speed := r.get_resource<Number>('numb')or {panic("")}
	println(speed.val)
	app.gg.draw_rect_filled(p.x,p.y,20,20,c.color)

	app.gg.end()
}
// this is a system that takes a mut entity and moves it 
fn  frame(mut  e ecs.Entity,mut r ecs.ResourceManger){
	mut pos := e.get_comp<Pos>() or {panic('')}
	pos.x++
}
```
# Notes:
- A compenet must embed ecs.Comp or have a active field 
- A Resource must embed ecs.Resource or have a name field 
