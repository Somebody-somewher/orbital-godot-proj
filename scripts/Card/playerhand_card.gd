extends Card
class_name PlayerHandCard

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
