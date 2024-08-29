class_name TriPriorityStack
extends PriorityStack

const LOW_PRIORITY := 0
const MED_PRIORITY := 1
const HIGH_PRIORITY := 2

const NUM_PRIORITIES := 3


func _init() -> void:
	set_priority_levels(NUM_PRIORITIES)
