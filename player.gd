extends CharacterBody3D

signal page_pickup(page)

@export var speed: float = 4.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.01
@export var run_speed_increase: float = 2.0
@export var stamina_recover: float = 5.0
@export var run_stamina_cost: float = 20.0
var stamina: float = 100.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Head.rotate_x(event.relative.y * mouse_sensitivity * -1)
		self.rotate_y(event.relative.x * mouse_sensitivity * -1)

		var camera_rot = $Head.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		$Head.rotation_degrees = camera_rot


func handle_input(delta: float) -> void:
	handle_page_pickup()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var speed_modifier = 1.0
	if Input.is_action_pressed("move_back"):
		speed_modifier = 0.8
	
	var stamina_cost = delta * run_stamina_cost
	if Input.is_action_pressed("run") and stamina > stamina_cost and velocity:
		speed_modifier *= run_speed_increase
		stamina -= stamina_cost
		print("stamina:", stamina)
	else:
		stamina += stamina_recover * delta
		stamina = min(stamina, 100.0)
	
	if direction:
		velocity.x = direction.x * speed * speed_modifier
		velocity.z = direction.z * speed * speed_modifier
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


func handle_physics(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func _physics_process(delta: float) -> void:
	handle_input(delta)
	handle_physics(delta)
	
func handle_page_pickup() -> void:
	if not Input.is_action_pressed("pick_up_page"):
		return
	
	$Head/RayCast3D.force_raycast_update()
	if not $Head/RayCast3D.is_colliding():
		print("nothing detected")
		return
				
	var collider = $Head/RayCast3D.get_collider()
	if collider.name == "Page" or collider.name == "PageCollision":
		emit_signal("page_pickup", collider)
		print("page detected")
