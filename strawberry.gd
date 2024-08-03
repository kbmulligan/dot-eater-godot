extends Area2D

const POINTS = 1
const BONUS_SPEED = 5

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    #print("processing strawberry ...")
    pass


func _on_body_entered(body):
    print(body.name, " - ate the strawberry")
    
    if (body.name == "player-char"):
        get_parent().get_node('%game_manager').add_points(POINTS)
        body.speed_up(BONUS_SPEED)
        body.eat()
    else:
        get_parent().get_node('%game_manager').add_points(-1 * POINTS)
    
    get_parent().get_node('%game_manager').add_strawberry()
    
    queue_free()
