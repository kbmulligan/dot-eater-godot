extends Area2D

const POINTS = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass


func _on_body_entered(body):
    print(body.name, " - ate the apple")
    
    if (body.name == "player-char"):
        get_parent().get_node('%game_manager').add_points(POINTS)
        body.eat()
    elif ("TYPE" in body and body.TYPE == "enemy"):
        get_parent().get_node('%game_manager').add_points(-1 * POINTS)
    
    # replace it
    get_parent().get_node('%game_manager').add_apple()
    
    # sometimes add an extra apple
    if randi() % 100 > 95:
        get_parent().get_node('%game_manager').add_apple()
    
    queue_free()
