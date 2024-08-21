extends CharacterBody3D

# Скорость вращения камеры
var mouse_sensitivity = 0.001

# Углы вращения
var rotation_x = 0.0
var rotation_y = 0.0

# Скорость движения игрока
var speed = 5.0

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

func _process(delta):
	var velocity = Vector3()

	if Input.is_action_pressed("ui_up"):
		velocity.z -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.z += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	velocity = velocity.normalized() * speed
	velocity = camera.global_transform.basis * velocity
	velocity.y = 0

	self.velocity = velocity
	move_and_slide()
