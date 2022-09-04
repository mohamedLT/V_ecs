module vecs

interface IResource {
	name string
}

pub struct Resource {
	name string
}

struct MutSysDecl {
pub:
	func  MutSystem
	comps []string
}

struct SysDecl {
pub:
	func  System
	comps []string
}

pub struct World {
pub mut:
	entities    []Entity
	systems     []SysDecl
	mut_systems []MutSysDecl
	resources   []IResource
}

pub fn (mut w World) add_resource(res IResource) {
	if !w.resources.any(it.name == res.name) {
		w.resources << res
	} else {
		eprintln('resource name is already used')
	}
}

pub fn (mut r ResourceManger) get_resource<T>(name string) ?&T {
	for res in r {
		if res.name == name {
			if res is T {
				return res
			}
		}
	}
	return error('resource not found ')
}

pub fn (mut w World) add_entity(comps []IComp) Entity {
	mut arr := []IComp{}
	for comp in comps {
		if comp !in arr {
			arr << comp
		}
	}
	e := Entity{
		id: w.entities.len
		comps: comps
	}
	w.entities << e
	return e
}

pub fn (mut w World) remove_entity(id int) {
	w.entities.delete(id)
}

pub fn (mut w World) step() {
	for i, _ in w.entities {
		entity := w.entities[i]
		for sys in w.systems {
			maped_comps := entity.comps.map(it.type_name())
			if sys.comps.all(it in maped_comps) {
				sys.func(entity, mut w.resources)
			}
		}
		mut mentity := w.entities[i]
		for sys in w.mut_systems {
			maped_comps := entity.comps.map(it.type_name())
			if sys.comps.all(it in maped_comps) {
				sys.func(mut mentity, mut w.resources)
			}
		}
	}
}

pub fn (mut w World) add_system(sys System, comps []IComp) {
	w.systems << SysDecl{
		func: sys
		comps: comps.map(it.type_name())
	}
}

pub fn (mut w World) add_system_mut(sys MutSystem, comps []IComp) {
	w.mut_systems << MutSysDecl{
		func: sys
		comps: comps.map(it.type_name())
	}
}

pub struct Comp {
pub mut:
	active bool
}

interface IComp {
mut:
	active bool
}

pub struct Entity {
pub:
	id int
pub mut:
	comps []IComp
}

pub fn (e Entity) get_comp<T>() ?&T {
	for c in e.comps {
		if c is T {
			return c
		}
	}
	return error('comp not found')
}

type System = fn (Entity, mut ResourceManger)

type MutSystem = fn (mut Entity, mut ResourceManger)

pub type ResourceManger = []IResource
