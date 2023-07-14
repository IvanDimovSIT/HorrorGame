extends CharacterBody3D

#maximum distance the enemy can see the player from
@export var max_sight_range: float = 40.0

#normal movement speed
@export var movement_speed: float = 2.0

#movement speed increase when chasing the player
@export var chase_speed_increase: float = 1.5

@export var instant_sight_distance: float = 4.0

#increase in the detextion range when chasing
@export var chase_proximity_instant_detection_increase: float = 2.

#current movement target use set_movement_target()
var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)

# array of arrays of node paths (of points)
@export var areas = []

#the player object
@export var player: Node 

const ACTIVITIES = ["PatrolingArea", "Chasing"]

var current_activity = ACTIVITIES[0]

#index of the current area
var current_area: int 

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D



func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	current_area = 0
	movement_target_position = self.position

func actor_setup() -> void:
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)
	$enemy_anim/AnimationPlayer.play("Walk")

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	movement_target_position = movement_target

func _physics_process(delta) -> void:
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	
	if current_activity == ACTIVITIES[1]:
		new_velocity = new_velocity * movement_speed * chase_speed_increase
	else:
		new_velocity = new_velocity * movement_speed

	velocity = new_velocity
	move_and_slide()


func look_at_target() -> void:
	#print("looking at ",movement_target_position)
	
	var direction = $NavigationAgent3D.get_next_path_position()
	direction.y = self.position.y
	if direction:
		look_at(direction, Vector3.UP)


func _process(delta) -> void:
	look_at_target()

func _on_timer_timeout() -> void:
	if can_see_player():
		current_activity = ACTIVITIES[1]
		set_movement_target(player.position)
		$enemy_anim/AnimationPlayer.play("Chase", -1, 1.5)
	elif is_at_location():
		if current_activity == ACTIVITIES[1]:
			current_activity = ACTIVITIES[0]
			$enemy_anim/AnimationPlayer.play("Walk")
			set_movement_target(get_area_closest_to_player())
			return
		current_activity = ACTIVITIES[0]
		$enemy_anim/AnimationPlayer.play("Walk")
		set_movement_target(pick_patrol_target())


func can_see_player() -> bool:
	if current_activity == ACTIVITIES[1] and self.position.distance_to(player.position) <= instant_sight_distance*chase_proximity_instant_detection_increase:
		return true
	elif self.position.distance_to(player.position) <= instant_sight_distance:
		return true
		
	if self.position.distance_to(player.position) > max_sight_range:
		return false
		
	var overlaps = $SightCone.get_overlapping_areas()
	print_debug("overlaps:",overlaps)
	if overlaps.size() <= 0:
		return false
	
	for i in overlaps:
		if i.name == "PlayerDetectionArea" or i.name == "Player":
			print("player in vision area")
			$SightRaycast.look_at(i.global_transform.origin, Vector3.UP)
			
			$SightRaycast.force_raycast_update()
			if not $SightRaycast.is_colliding():
				print("raycast not detecting anything")
				
				return false
				
			var collider = $SightRaycast.get_collider()
			
			# Set option: Collide with areas = true
			if collider.name == "PlayerDetectionArea" or collider.name == "Player":
				print("player in LOS")
				return true
			
			print("player not detected, instead:", collider.name)
	
	return false

func pick_patrol_target() -> Vector3:
	if randf() < 0.1: # move closer to player
		print("moving to area closest to player")
		return get_area_closest_to_player()
	
	if randf() < 0.7: # in the same area
		print("patroling in the same area")
		var pottential_targets = areas[current_area]
		return get_node_or_null(pottential_targets[randi_range(0, pottential_targets.size()-1)]).position
	else:
		print("moving to different area")
		var target_area = areas[randi_range(0, areas.size()-1)]
		return get_node_or_null(target_area[randi_range(0, target_area.size()-1)]).position

func is_at_location() -> bool:
	var target_ignore_y = Vector3(movement_target_position.x,self.position.y,movement_target_position.z)
	return self.position.distance_to(target_ignore_y) <= 2.0
	
func get_area_closest_to_player() -> Vector3:
	var all_areas = []
	for i in areas:
		for j in i:
			all_areas.append(get_node_or_null(j).position)
	
	var closest_dist = player.position.distance_to(all_areas[0])
	var closest = all_areas[0]
	for i in all_areas:
		var curr_distance = player.position.distance_to(i)
		if curr_distance < closest_dist:
			closest_dist = curr_distance
			closest = i
	
	return closest
