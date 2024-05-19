# Resizer window - (No source - Custom made)
class_name Resizer_Window extends Window

var children : Array = []

func _ready():
	self.size_changed.connect(self.resize_children)
	self.child_order_changed.connect(self.update_child_list)
	
func resize_children():
	for child in children:
		child.size = self.size
		child.minimum_size = self.size
	
func update_child_list():
	children = get_children()
