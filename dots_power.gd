extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
    for child in get_children():
        child.connect("eat_power_dot", $"../game_manager".eat_power_dot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass


#func _on_child_entered_tree(node):
#    node.connect("eat_dot", $"../game_manager".check_dots_remaining)
