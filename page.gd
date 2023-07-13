extends MeshInstance3D

@export var player: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	player.page_pickup.connect(_on_page_pickup)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_page_pickup(page):
	if page == self or page == $PageCollision:
		queue_free()
