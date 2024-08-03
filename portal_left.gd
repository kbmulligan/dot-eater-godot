extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass


func _on_body_entered(body):
    if (body.velocity.x < 0):
        print(body.name + " moving left, so teleporting ... ")
        body.position += Vector2(%teleporters.DISTANCE_TO_PORTAL, 0)

