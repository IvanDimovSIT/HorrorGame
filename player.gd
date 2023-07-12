extends CharacterBody3D


@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.01

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
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
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
