extends CharacterBody2D

signal respawn(my_original_phase : String)

const TYPE = "enemy"
const POINTS = 50

const VULNERABLE_TIME_SEC : int = 8

const verbose = false

const DIFFICULTY_FACTOR = 0.4
const ENEMY_SPEED = 120.0
var speed = ENEMY_SPEED * DIFFICULTY_FACTOR
#const JUMP_VELOCITY = -400.0

const BLUE_SPEED_FACTOR = -0.5

const GOAL_TIME = 0.3

const phases = ['blinky', 'clyde', 'inky', 'pinky', 'blue']
@export var phase = 'blinky'

const states = ['chase', 'run', 'lead', 'random']
@export var state = 'chase'

var old_phase = phase

var time_on_goal = 0
var current_movement = get_new_movement()

var frozen : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var saved_speed : float = 0

@onready var navigator = $NavigationAgent2D
@onready var gm = get_parent().get_parent().get_node("game_manager")

var being_killed = false

func _ready():
    add_to_group("enemies")
    if (phase not in phases):
        random_phase()
        old_phase = phase
    else:
        switch_phase(phase)
        old_phase = phase

    print("Ready and child of : ", gm.name)
    respawn.connect(gm.respawn_ghost)

func freeze():
    print("Freezing: ", name)
    saved_speed = speed
    speed = 0
    frozen = true
    current_movement = { "x": 0.0, "y": 0.0}
    $CollisionShape2D.set_deferred("disabled", true)
    $AnimatedSprite2D.pause()

func unfreeze():
    speed = saved_speed
    frozen = false
    $AnimatedSprite2D.play()
    $CollisionShape2D.set_deferred("disabled", false)
    
func kill():
    if not being_killed:
        being_killed = true
        print("%s is being killed. ---------------------------- <<< " % name)
        respawn.emit(old_phase)
        queue_free()

func start_vulnerable():
    #old_phase = phase if phase != 'blue' else 
    switch_phase("blue")
    $phase_timer.start(VULNERABLE_TIME_SEC)
    var tween1 = get_tree().create_tween()
    tween1.tween_method(blink, 1.0, 0.0, 2).set_delay(VULNERABLE_TIME_SEC - 6.0)
    var tween2 = get_tree().create_tween()
    tween2.tween_method(blink, 1.0, 0.0, 1).set_delay(VULNERABLE_TIME_SEC - 4.0)
    var tween3 = get_tree().create_tween()
    tween3.tween_method(blink, 1.0, 0.0, 1).set_delay(VULNERABLE_TIME_SEC - 3.0)
    var tween4 = get_tree().create_tween()
    tween4.tween_method(blink, 1.0, 0.0, 1).set_delay(VULNERABLE_TIME_SEC - 2.0)
    var tween5 = get_tree().create_tween()
    tween5.tween_method(blink, 1.0, 0.0, 0.5).set_delay(VULNERABLE_TIME_SEC - 1.0)
    var tween6 = get_tree().create_tween()
    tween6.tween_method(blink, 1.0, 0.0, 0.5).set_delay(VULNERABLE_TIME_SEC - 0.5)
    

func restore_phase():
    switch_phase(old_phase)

func random_phase():
    switch_phase(phases[randi() % len(phases)])

func switch_phase(new_phase):
    phase = new_phase
    
    if (phase in phases):
        $AnimatedSprite2D.play(phase)
    else:
        $AnimatedSprite2D.play('blinky')
        print(name, ': Invalid phase selected')
        
func blink(intensity : float):
    $AnimatedSprite2D.material.set_shader_parameter("blink_intensity", intensity)

func get_new_movement():
    print('New movement ...')
    var direction_code = randi() % 5
    var direction = get_direction_from_code(direction_code) 
    
    var vel_x = 0
    var vel_y = 0
    
    if direction == 'left':
        vel_x = speed * -1
        if speed != 0:
            set_skew(-PI * 10/180)
    elif direction == 'right':
        vel_x = speed * 1
        if speed != 0:
            set_skew(PI * 10/180)
    elif direction == 'up':
        vel_y = speed * -1
        if speed != 0:
            set_skew(0)
    elif direction == 'down':
        vel_y = speed * 1
        if speed != 0:
            set_skew(0)
    else:
        vel_x = move_toward(velocity.x, 0, speed)
        vel_y = move_toward(velocity.y, 0, speed)

    var vel = { "x": vel_x, "y": vel_y}
    return vel

func get_ghost_movement(delta):
    var movement = current_movement
    time_on_goal += delta
    
    if (false and phase in phases):
        #print("Getting blinky movement ...")
        
        current_movement = movement
    elif (time_on_goal > GOAL_TIME):
        time_on_goal = 0
        if phase in ['blinky', 'pinky', 'inky']:
            movement = get_blinky_movement(delta)
        else:
            movement = get_blue_movement(delta)
            
        current_movement = movement
        if verbose: 
            print('%s choosing new direction ...' % name)
    else:
        movement = current_movement
    
    return movement
    
func get_player_position():
    return get_tree().get_nodes_in_group("player")[0].global_position

func update_nav_target():
    navigator.target_position = get_player_position()
    
func get_blinky_movement(_delta):
    update_nav_target()
    
    var vector : Vector2 = (navigator.get_next_path_position() - global_position).normalized()
    
    var movement = { 
        "x": vector.x * speed * 0.9, 
        "y": vector.y * speed * 0.9
    }
    print(name, '/ ', movement, " / finished: ", navigator.is_navigation_finished())
    return movement

func get_blue_movement(_delta):
    navigator.target_position = get_tree().get_nodes_in_group("player")[0].global_position
    var vector : Vector2 = (navigator.get_next_path_position() - global_position).normalized()
    
    var movement = { 
        "x": vector.x * speed * BLUE_SPEED_FACTOR, 
        "y": vector.y * speed * BLUE_SPEED_FACTOR
    }
    print(name, '/ ', movement, " / finished: ", navigator.is_navigation_finished())
    return movement
    
func _physics_process(delta):

    var new_vel = get_ghost_movement(delta)
    var new_velocity : Vector2 = Vector2()
    new_velocity.x = new_vel.x
    new_velocity.y = new_vel.y
    #print(name, " / vel:", velocity)
    if navigator.avoidance_enabled:
        navigator.velocity = new_velocity
    else:
        _on_navigation_agent_2d_velocity_computed(new_velocity)
    
func get_direction_from_code(code):
    var direction = ''
    if (code == 1):
        direction = 'left'
    elif (code == 2):
        direction = 'right'
    elif (code == 3):
        direction = 'up'
    elif (code == 4):
        direction = 'down'
    else:
        direction = 'idle'
    return direction


func _on_phase_timer_timeout():
    print("phase_timer_timeout")
    restore_phase()


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
    velocity = safe_velocity
    move_and_slide()
    check_collisions()

func check_collisions():
    for i in get_slide_collision_count():
        var collider = get_slide_collision(i).get_collider()
        if verbose:
            print(name, " collided with ", collider.name)
        
func _on_killzone_body_entered(body):
    #print("killzone body entered: ", body.name)
    if (body.is_in_group("player")):
            if (phase == 'blue'):
                print(name, " had the player kill him while blue.")
                kill()
            else:
                print(name, " collided with the player -- THE PLAYER SHOULD BE DEAD I SAY!!!")
                body.damage()
