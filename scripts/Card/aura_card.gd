extends Card
class_name AuraCard

#var auras : Array[EventModifier]	

# called when added to player hand
func initialize_card_effect() -> void:
	pass
	#for aura_data in data.

# called when added to board
# fully replace card with effect, then free self instance
func swap_to_effect(_scale_by: Vector2) -> void:
	pass
#
#func modify_events(arr : Array[BoardEvent]) -> Array[BoardEvent]:
	#var ret_arr = arr
	#for modifier in auras:
		#ret_arr = modifier.flat_modify(ret_arr)
	#return ret_arr


func highlight_card(on : bool, tweening : Tween):
	if tweening and tweening.is_running():
		await tweening.finished
	tweening = get_tree().create_tween()
	if on:
		tweening.parallel().tween_property(self, "scale", Vector2(1.15, 1.15), 0.08)
	else:
		tweening.parallel().tween_property(self, "scale", Vector2.ONE, 0.08)
