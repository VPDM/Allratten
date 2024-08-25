extends RigidBody3D

@export var sensivity = 0.5

func recieve_mouse_control(mouse_movement):
	# применяем силу на поворот по оси Y, со значением движения мыши * чувствительность
	angular_velocity.y = mouse_movement.x * sensivity
