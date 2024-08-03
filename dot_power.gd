extends Area2D

signal eat_power_dot

# Called when the node enters the scene tree for the first time.
func _ready():
    #connect("eat_dot", $"../game_manager".check_dots_remaining)
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass

func _on_body_entered(body):
    if (body.is_in_group("player")):
        eat_power_dot.emit()
        queue_free()
