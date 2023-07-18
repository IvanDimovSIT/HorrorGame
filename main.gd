extends Node

var picked_up_pages : int = 0
var total_pages_count : int = 0

func _on_forrest_level_page_picked_up():
	picked_up_pages += 1
	$GUI/HUD.show_pages(picked_up_pages, total_pages_count)
	if picked_up_pages >= total_pages_count:
		$ForrestLevel.queue_free()
		$GUI.display_survive_screen()


func _on_forrest_level_player_killed():
	$ForrestLevel.queue_free()
	$GUI.display_death_screen()


func _on_forrest_level_player_stamina_changed(stamina):
	$GUI/HUD.update_stamina_bar(stamina)


func _on_forrest_level_ready():
	total_pages_count = $ForrestLevel.get_start_pages_count()
