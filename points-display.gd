extends Label



# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    var format_string = "{points}"    
    var new_text = format_string.format({"points": %game_manager.player_points})
    set_text(new_text)
