extends HTTPRequest


# Called when the node enters the scene tree for the first time.
func _ready():
    print("http request ready ...")
    #do_rainbow()
    
    
func do_rainbow():
    request("http://10.0.0.20:8000/lights/rainbow")

func turn_off():
    request("http://10.0.0.20:8000/lights/off")

func response_callback():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
