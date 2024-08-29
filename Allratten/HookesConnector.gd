extends Node3D


@export var Target:Node3D
@export var Body:RigidBody3D
@export var Active:bool = true

@export var linearSpringStiffness = 400
@export var linearSpringDamping = 50
@export var maxLinearForce = 100
@export var angularSpringStiffness = 800
@export var angularSpringDamping = 30
@export var maxAngularForce = 400;


func UpdateVelocity(delta):
	# если нет ни тела ни точки, завершаем функцию
	if (Target == null): return
	if (Body == null): return
	if (!is_instance_valid(Target)): return;
	if (!is_instance_valid(Body)): return;
	
	var targetTransform:Transform3D  = Target.global_transform;
	var currentTransform:Transform3D = Body.global_transform;
	
	var rotationDifference:Basis = targetTransform.basis * currentTransform.basis.inverse();
	var positionDifference:Vector3 = targetTransform.origin - currentTransform.origin;
	
	var force:Vector3 = HookesLaw(positionDifference, Body.linear_velocity, linearSpringStiffness, linearSpringDamping)
	force = force.limit_length(maxLinearForce);
	Body.linear_velocity += force * delta;
		
	var torque:Vector3 = HookesLaw(rotationDifference.get_euler(), Body.angular_velocity, angularSpringStiffness, angularSpringDamping)
	torque = torque.limit_length(maxAngularForce)

	Body.angular_velocity += torque * delta;
	
func _physics_process(delta):
	if(Active): UpdateVelocity(delta);

# закон Гука
func HookesLaw(displacement:Vector3, currentVelocity:Vector3, stiffness:float, damping:float):
	return (stiffness * displacement) - (damping * currentVelocity)

