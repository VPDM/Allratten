extends CharacterBody3D

# Длина луча, используемого для захвата объектов
var ray_length = 5.0

# Расстояние, на которое захваченный объект будет перемещен относительно камеры
var grab_distance = 1.0

# Ссылка на захваченный объект
var grabbed_object = null

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
		# проверяем управляет ли камера каким нибудь интерактивным объектом
		if !camera.is_controlling:
			# Обновляем вращение камеры
			rotation_x -= event.relative.y * mouse_sensitivity
			rotation_y -= event.relative.x * mouse_sensitivity

			# Ограничиваем вращение по оси X, чтобы избежать сальтухи ептить ее в сраку, долго доперал как это сделать
			rotation_x = clamp(rotation_x, deg_to_rad(-89), deg_to_rad(89))
			camera.rotation_degrees = Vector3(rad_to_deg(rotation_x), rad_to_deg(rotation_y), 0)

func _physics_process(delta):
	var movement = Vector3()

	if Input.is_action_pressed("up"):
		movement.z -= 1
	if Input.is_action_pressed("down"):
		movement.z += 1
	if Input.is_action_pressed("left"):
		movement.x -= 1
	if Input.is_action_pressed("right"):
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
	
	#
	# Хня для поднятия предметов, (не получилась)
	#
	
	if Input.is_action_just_pressed("grab"):
		grab_object()
	elif Input.is_action_just_released("grab"):
		release_object()

func grab_object():
	# Если объект уже захвачен, выходим из функции
	if grabbed_object:
		return

	# Получаем объект камеры
	var camera = get_node("Camera3D")

	# Получаем глобальное положение и ориентацию камеры
	var camera_transform = camera.get_global_transform()

	# Объект для представления направления луча, используя глобальное положение и ориентацию камеры
	var ray_direction = camera_transform.basis.z

	var space_state = get_world_3d().direct_space_state

	# Создаем объект PhysicsRayQueryParameters3D для определения параметров запроса луча
	var query = PhysicsRayQueryParameters3D.new()

	# Устанавливаем начальную точку луча в глобальное положение камеры
	query.from = camera_transform.origin

	# Устанавливаем конечную точку луча в расстоянии ray_length от начальной точки в направлении луча
	query.to = camera_transform.origin + ray_direction * ray_length

	# Устанавливаем флаги для запроса луча
	query.collide_with_areas = false
	query.collide_with_bodies = true

	# Исключаем сам объект из запроса луча
	query.exclude = [self]

	# Выполняем запрос луча и получаем результат
	var result = space_state.intersect_ray(query)

	# Если результат содержит объект, с которым пересекается луч, захватываем его
	if result.get("collider"):
		grabbed_object = result.get("collider")

		# Устанавливаем позицию захваченного объекта в расстоянии grab_distance от камеры в направлении луча
		grabbed_object.set_transform(Transform3D(Basis.IDENTITY, get_global_transform().origin + get_global_transform().basis.z * grab_distance))

		# Добавляем захваченный объект в древо сцены в качестве дочернего объекта текущего объекта
		add_child(grabbed_object)

		# Останавливаем физические вычисления для захваченного объекта
		grabbed_object.set_physics_process(false)

# Функция для освобождения захваченного объекта
func release_object():
	# Если объект захвачен, освобождаем его
	if grabbed_object:
		# Удаляем захваченный объект из древа сцены
		grabbed_object.get_parent().remove_child(grabbed_object)

		# Возобновляем физические вычисления для захваченного объекта
		grabbed_object.set_physics_process(true)

		# Устанавливаем ссылку на захваченный объект в null
		grabbed_object = null
