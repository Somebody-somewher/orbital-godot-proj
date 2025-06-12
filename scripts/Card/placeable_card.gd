extends Card
class_name PlaceableCard

var building : PlaceableNode

# called when added to player hand
func initialize_card_effect() -> void:
	building = Building.new_building(id_name)
	building.visible = true
	building.get_node("Area2D/CollisionShape2D").disabled = true

# called when added to board
# fully replace card with effect, then free self instance
func swap_to_effect(scale_by: Vector2) -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	building.visible = true
	building.get_node("Area2D/CollisionShape2D").disabled = false
	queue_free()

func highlight_card(on : bool, tweening : Tween):
	if tweening and tweening.is_running():
		await tweening.finished
	tweening = get_tree().create_tween()
	if on:
		self.rotation = 0
		tweening.parallel().tween_property(self, "position", Vector2(0, -80 * deck_scale) + deck_pos, 0.08)
		tweening.parallel().tween_property(self, "scale", Vector2(1.15, 1.15) * deck_scale, 0.08)
	else:
		self.rotation = deck_angle
		tweening.parallel().tween_property(self, "position", Vector2.ZERO + deck_pos, 0.08)
		tweening.parallel().tween_property(self, "scale", Vector2.ONE * deck_scale, 0.08)
