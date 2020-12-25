extends MeshInstance

var new_mesh: MeshInstance
var root_qt_node: QuadTree


func _ready() -> void:
	randomize()
	# create quadtree
	var spatial_mat = SpatialMaterial.new()
	spatial_mat.albedo_color = Color(0, 0, 0, 1)
	root_qt_node = QuadTree.new(AABB(Vector3(-50, 0, -50), Vector3(100, 0, 100)), 3, 8, 0, null, spatial_mat, get_node("/root/Spatial/ImmediateGeometry"))
	# create 100 objects to test out quad tree
	for i in range(100):
		# create new mesh instance
		var new_mesh = MeshInstance.new()
		# create a new cube mesh
		var cube_mesh = CubeMesh.new()
		# set it's size random from 2, 4 
		cube_mesh.size = Vector3(rand_range(2, 4), 0, rand_range(2, 4))
		new_mesh.mesh = cube_mesh
		# set the position random from -25 to 25 -- size of the terrain
		new_mesh.set_translation(Vector3(rand_range(-50, 50), 0, rand_range(-50, 50)))
		add_child(new_mesh)
		# add it into the quad tree
		root_qt_node.add_body(new_mesh)
	
	# test query -- create a new sphere mesh and set it's radius to 5
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = rand_range(5, 8)
	sphere_mesh.height = 0.1
	# create a new meshinstance and set it's translation to `Vector3(4, 0, 4)`
	new_mesh = MeshInstance.new()
	new_mesh.set_translation(Vector3(rand_range(2, 6), 0, rand_range(2, 6)))
	# hide it, because we don't want it to be shown.
#	new_mesh.hide()
	# set the mesh and add it into the scene
	new_mesh.mesh = sphere_mesh
	add_child(new_mesh)
	# query the QuadTree with the sphere mesh's Tranformed AABB
	var returned_objects = root_qt_node.query(new_mesh.get_transformed_aabb())
	
	# print the returned objects
#	print(returned_objects)
#	print(returned_objects.size())

	# visualize the quad tree
	root_qt_node.draw(0.2)
	

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left_button"):
		var mouse_pointer = get_viewport().get_mouse_position()
		var camera = get_viewport().get_camera()
		var from = camera.project_ray_origin(mouse_pointer)
		var to = from + camera.project_ray_normal(mouse_pointer) * 1000
		var ray = get_world().direct_space_state.intersect_ray(from, to, [self, camera])
		if !ray.empty():
			new_mesh.set_translation(ray['position'])
			var transformed_aabb = new_mesh.get_transformed_aabb()
			transformed_aabb.size.y = INF
			var returned_objects = root_qt_node.query(transformed_aabb)
			for object in returned_objects:
#				print(object)
				root_qt_node.remove_body(object)
			root_qt_node.draw(0.2, true)
