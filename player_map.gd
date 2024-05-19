extends Resizer_Window


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_transform_gui_input(event):
	if Input.is_action_pressed("LMC") and event is InputEventMouseMotion:
		$transform.position += event.relative
