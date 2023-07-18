extends Control


func show_pages(current_count: int, total_count: int) -> void:
	$PageCountLabel.text = "Pages:" + str(current_count) + "/" + str(total_count)
	$PageCountLabel.show()
	$Timer.start()


func _on_timer_timeout() -> void:
	$PageCountLabel.hide()


func update_stamina_bar(stamina: float) -> void:
	$StaminaBar.value = stamina 
