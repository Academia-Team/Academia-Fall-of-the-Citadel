extends Reference
class_name Queue

var array
var array_sz
var read_idx
var write_idx
var overwritten


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init(size):
	array = Array()
	array_sz = size
	
	for _i in range(0, size):
		array.append(0)
	
	read_idx = 0
	write_idx = 0
	overwritten = false

func has_overwritten():
	return overwritten
	
func clear():
	read_idx = 0
	write_idx = 0
	overwritten = false
	
func queue(val):
	array[write_idx] = val
	write_idx = (write_idx + 1) % array_sz
	
	if write_idx == read_idx:
		overwritten = true
		read_idx = (read_idx + 1) % array_sz
	
func dequeue():
	var val = peek()
	
	if val:
		read_idx = (read_idx + 1) % array_sz
	
	return val

func empty():
	return read_idx >= write_idx

func peek():
	if read_idx >= write_idx:
		return null
	return array[read_idx]

func contains(val):
	if not empty():
		for i in range(read_idx, write_idx):
			if array[i] == val:
				return true
	return false
