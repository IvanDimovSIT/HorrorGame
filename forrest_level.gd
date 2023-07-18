extends Node3D

signal player_killed
signal page_picked_up
signal player_stamina_changed(stamina)

func _on_enemy_kill_player():
	player_killed.emit()
	

func _on_player_page_pickup(page):
	page_picked_up.emit()


func _on_player_stamina_changed(stamina):
	player_stamina_changed.emit(stamina)


func get_start_pages_count() -> int:
	return $Pages.get_child_count()
