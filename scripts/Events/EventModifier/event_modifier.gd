extends Resource
class_name EventModifier

# modifies a board event that occurs
func modify(event_arr : BoardEvent) -> Array[BoardEvent]:
	return []

# flatmaps an array of events
func flat_modify(event_arr : Array[BoardEvent]) -> Array[BoardEvent]:
	var ret_arr : Array[BoardEvent] = []
	for event in event_arr:
		ret_arr.append(modify(event))
	return ret_arr
