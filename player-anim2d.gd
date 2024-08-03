extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    var player = get_parent()
    if player.velocity.x < 0:
        play("left")
    elif player.velocity.x > 0:
        play("right")
    elif player.velocity.y < 0:
        play("up")
    elif player.velocity.y > 0:
        play("down")
    else:
        pass
        
