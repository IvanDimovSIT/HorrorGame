extends Control

func display_death_screen() -> void:
	$HUD.hide()
	$DeathScreen.show()
	$DeathScreen/DeathScreenTimer.start()


func display_survive_screen() -> void:
	$HUD.hide()
	$SurviveScreen.show()
	$SurviveScreen/SurviveScreenTimer.start()

func _on_death_screen_timer_timeout():
	get_tree().quit()


func _on_survive_screen_timer_timeout():
	get_tree().quit()
