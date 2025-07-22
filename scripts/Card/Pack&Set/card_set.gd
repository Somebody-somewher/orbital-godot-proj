extends Node2D
class_name CardSet

var cards_in_set : Array[Card]
var destroyed : bool = false
var set_id : String 
var cardpack_id : int

var card_dict : Dictionary[String, int] = {}
var pop_up_desc : String

func set_up(card_set : Array, set_id : String, cardpack_id : int) -> void:
	cards_in_set.assign(card_set)
	self.set_id = set_id
	self.cardpack_id = cardpack_id
	pass

@onready
var card_manager = get_tree().root.get_node("GameManager/CardManager")

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var z_count = 100
	Signalbus.connect("confirmed_add_to_hand",_shift_to_hand)
	for card_instance in cards_in_set: ##card_type is of form [CardInstance]
		card_instance.z_index = z_count
		card_instance.get_node("Area2D/CollisionShape2D").disabled = true
		add_child(card_instance)
		var card_name = card_instance.get_node("Texts/CardName").text
		if card_name in card_dict:
			card_dict.set(card_name, card_dict.get(card_name) + 1)
		else:
			card_dict.set(card_name, 1)
		z_count += 2
	
	var text = []
	for key in card_dict:
		var value = card_dict[key]
		text.append(str(value) + "x " + key)
	label.text = "\n".join(text)

# adds each card to player hand
func shift_to_hand() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	destroyed = true
	CardLoader.card_mem.attempt_cardset_to_hand.rpc_id(1, cardpack_id, set_id,\
		 PlayerManager.getUUID_from_PeerID(multiplayer.get_unique_id()))

func _shift_to_hand(cards : Array[String], set_id : String) -> void:
	if self.set_id != set_id:
		return 
	
	for card_id in cards:
		for card_in_set in cards_in_set:			
			if card_id in card_in_set.get_data_instance_id():
				cards_in_set.erase(card_in_set)
				Signalbus.emit_signal("register_to_cardmanager", card_in_set)
				Signalbus.emit_signal("add_to_hand", card_in_set)
			break			
	
	for remainder in cards_in_set:
		remainder.dissolve_card()
#=======
	#for set_card in card_set:
		#set_card.reparent(card_manager)
		#card_manager.connect_card_signals(set_card)
		##set_card.connect_to_card_manager(card_manager)
		#if set_card is PlaceableCard:
			#card_manager.player_hand_ref.add_to_hand(set_card)
		#elif set_card is AuraCard:
			#card_manager.aura_cards.add(set_card)
		#set_card.get_node("Area2D/CollisionShape2D").disabled = false
#>>>>>>> Condition-and-Effects-Expansion

func _on_area_2d_mouse_entered() -> void:
	highlight_set(true)
	
func _on_area_2d_mouse_exited() -> void:
	if !destroyed:
		highlight_set(false)

# fans out cards
func highlight_set(on : bool) -> void:
	for i in range(cards_in_set.size()):
		if on:
			var fan_angle = clamp(cards_in_set.size() * 0.2, 0, PI/2)
			var new_tilt = 0 if cards_in_set.size() == 1 else (i - (float(cards_in_set.size()) - 1)/2) * fan_angle / (cards_in_set.size() - 1)
			var x = 100 * sin(new_tilt);
			var y = -60 * cos(new_tilt) + 30;
			animate_card(cards_in_set[i], new_tilt, 1.1, Vector2(x, y))
			label.visible = true
		else:
			animate_card(cards_in_set[i], 0, 1, Vector2(0,0))
			label.visible = false

func animate_card(card : Card, new_angle : float, new_scale : float, pos : Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", pos, 0.05)
	tween.parallel().tween_property(card, "rotation", new_angle, 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(new_scale, new_scale), 0.1)

func dissolve_set() -> void:
	for unchosen_card in cards_in_set:
		unchosen_card.dissolve_card()
