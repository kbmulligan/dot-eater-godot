extends CharacterBody2D

const RESTART_THRESHOLD = 5

const MAX_SPEED = 130.0

const UP_SCALE = 1.2
const DOWN_SCALE = 0.835
const UP_SCALE_TOUCH = 1.01
const DOWN_SCALE_TOUCH = 0.99

# const node_name = "PLAYER"

var speed : float = 150.0
var saved_speed : float = 0.0
var dying : bool = false
var frozen : bool = false

func freeze(continue_animation : bool = false):
    print("Freezing: ", name)
    saved_speed = speed
    frozen = true
    speed = 0
    $player_collision_2d.set_deferred("disabled", true)
    if not continue_animation:
        $AnimatedSprite2D.pause()

func unfreeze():
    frozen = false
    speed = saved_speed
    $AnimatedSprite2D.play()
    $player_collision_2d.set_deferred("disabled", false)

func _ready():
    add_to_group("player")
    

func speed_up(speed_change : int = 1):
    speed += speed_change
    
func grow(touch : bool = false):
    if touch:
        self.apply_scale(Vector2(UP_SCALE_TOUCH, UP_SCALE_TOUCH))
    else: 
        self.apply_scale(Vector2(UP_SCALE, UP_SCALE))
    
func shrink(touch : bool = false):
    if touch:
        self.apply_scale(Vector2(DOWN_SCALE_TOUCH, DOWN_SCALE_TOUCH))
    else:
        self.apply_scale(Vector2(DOWN_SCALE, DOWN_SCALE))
    
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            %game_manager.quit()
        if event.pressed and event.keycode == KEY_X:
            if not %game_manager.game_is_won():
                %game_manager.win()
        if event.pressed and event.keycode == KEY_ESCAPE:
            %game_manager.quit()
        if event.pressed and event.keycode == KEY_U:
            grow()
        if (event.pressed and event.keycode == KEY_J):
            shrink()
            
    if event is InputEventMagnifyGesture:
        if event.factor > 1.0:
            grow(true)
        if event.factor < 1.0:
            shrink(true)
            
    if event is InputEventScreenTouch:
        # print("Input TOUCH Event")
        pass
        
    elif event is InputEventScreenDrag:
        #print("Input DRAG Event")
        
        var vx = event.velocity.x
        var vy = event.velocity.y
        
        if (abs(vx) > abs(vy)):
            #print('x dominant')
            velocity.y = 0
            velocity.x = min(vx, speed) if vx > 0 else max(vx, -1 * speed)
        else:
            #print('y dominant')
            velocity.x = 0
            velocity.y = min(vy, speed) if vy > 0 else max(vy, -1 * speed)
        
        

func _physics_process(_delta):

    if Input.is_action_just_pressed("toggle_pause"):
        %game_manager.toggle_pause()
        
    if Input.is_action_pressed("move_left"):
        velocity.x = speed * -1
        velocity.y = 0
        
    if Input.is_action_pressed("move_right"):
        velocity.x = speed * 1
        velocity.y = 0
    
    if Input.is_action_pressed("move_up"):
        velocity.y = speed * -1
        velocity.x = 0
        
    if Input.is_action_pressed("move_down"):
        velocity.y = speed * 1
        velocity.x = 0
    
    if frozen:
        velocity.y = 0
        velocity.x = 0
    
    move_and_slide()
    check_collisions()
    play_animation()

func play_animation():
    
    if dying:
        $AnimatedSprite2D.play("dying")
    else:
        if velocity.x < 0:
            $AnimatedSprite2D.play("left")
        elif velocity.x > 0:
            $AnimatedSprite2D.play("right")
        elif velocity.y < 0:
            $AnimatedSprite2D.play("up")
        elif velocity.y > 0:
            $AnimatedSprite2D.play("down")
        else:
            pass
        
func check_collisions():
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        var collider = collision.get_collider()
        #print("Player collided with ", collider.name)
        
        if ("TYPE" in collider and collider.TYPE == "enemy"):
            #%game_manager.add_points(collider.POINTS)
            #collision.get_collider().kill()
            if collider.phase == "blue":
                collision.get_collider().kill()
            else:
                print("I have collided with an enemy whilst they are not vulnerable ...")
                #damage()

func damage():
    die()
    
func die():
    dying = true
    print("Player died!")
    
    %game_manager.lose()

func eat():
    #print("Player eating something ...")
    #$eat_sound.play()
    $waka_sound.play()

func eat_power_dot():
    print("Player eating power dot ...")
    $power_up_sound.play()
    %game_manager.transform_ghosts()
