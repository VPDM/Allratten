extends CharacterBody3D

# Скорость вращения камеры
var mouse_sensitivity = 0.001

# Углы вращения
var rotation_x = 0.0
var rotation_y = 0.0

# Скорость движения игрока
var speed = 5.0
var gravity = 50

# Ссылка на камеру
var camera: Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera = $Camera3D

func _input(event):
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_y -= event.relative.x * mouse_sensitivity

		# Ограничиваем вращение по оси X, чтобы избежать сальтухи ептить ее в сраку, долго доперал как это сделать
		rotation_x = clamp(rotation_x, deg_to_rad(-89), deg_to_rad(89))

		# Обновляем вращение камеры
		camera.rotation_degrees = Vector3(rad_to_deg(rotation_x), rad_to_deg(rotation_y), 0)

func _physics_process(delta):
	var movement = Vector3()

	if Input.is_action_pressed("ui_up"):
		movement.z -= 1
	if Input.is_action_pressed("ui_down"):
		movement.z += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
		
	if Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_pressed("fire"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	movement = movement.normalized() * speed
	movement = camera.global_transform.basis * movement
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10
	velocity.y -= gravity * delta
	
	self.velocity = Vector3(movement.x, velocity.y, movement.z)
	move_and_slide()
	
	for col_idx in get_slide_collision_count():
		var col = get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 0.3)
			#col.get_collider().apply_impulse(-col.get_normal() * 0.01, col.get_position())
