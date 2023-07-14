extends MeshInstance3D

@export var player: Node

func _ready() -> void:
	player.page_pickup.connect(_on_page_pickup)


func _on_page_pickup(page) -> void:
	if page == self or page == $PageCollision:
		queue_free()
