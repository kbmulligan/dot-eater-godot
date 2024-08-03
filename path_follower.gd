extends PathFollow2D

signal make_dot(position : Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
    
    const START = 0
    var END = get_parent().get_curve().get_baked_length()
    const STEP = 35
    
    for prog in range(START, END, STEP):
        set_progress(float(prog))
        print("Dot dropper: ", progress)
        make_dot.emit(position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
