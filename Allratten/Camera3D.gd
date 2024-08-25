extends Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
var controlling_object = null
var is_controlling = false

func _input(event):
	if event is InputEventMouseMotion:
		if is_controlling and controlling_object!=null:
			controlling_object.recieve_mouse_control(event.relative)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	
	var from = global_position
	var to = from - global_transform.basis.z * 2.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	# есть ли какие нибудь столкновения
	if result.size() > 0:
		# если у объекта с которым столкнулся луч есть функция для управления
		if result.collider.has_method("recieve_mouse_control"):
			# при нажатии ЛКМ
			if Input.is_action_just_pressed("fire"):
				# устанавливаем состояние управления и объект которым управляем
				is_controlling = true
				controlling_object = result.collider
	
	# при отпускании кнопки ЛКМ сбрасываем состояние управления и объект которым управляем
	if Input.is_action_just_released("fire"):
		is_controlling = false
		controlling_object = null
			
