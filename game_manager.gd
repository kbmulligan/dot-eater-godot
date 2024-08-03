extends Node

const SCREEN_WIDTH = 720
const SCREEN_HEIGHT = 1280

const USABLE_WIDTH = 710
const USABLE_HEIGHT = 1200

const STARTING_APPLES = 0
const STARTING_STRAWBERRIES = 0
const RESTART_THRESHOLD = 1000

const MAX_SPAWN_RANGE_X = 300
const MAX_SPAWN_RANGE_Y = 300

const SPAWN_BIAS_X = 0
const SPAWN_BIAS_Y = -60

const MAX_ENEMY_SPAWN_RANGE_X = 1
const MAX_ENEMY_SPAWN_RANGE_Y = 1

const MOBILE_PLATFORMS = ['Android', 'iOS']

var platform : String = 'UNKNOWN'
var platform_is_mobile : bool = false
var player_points : int = 0

const DOT_POINTS : int = 1
const POWER_DOT_POINTS : int = 25

const RESPAWN_TIME_SEC = 3.0

const GHOST_RADIUS = 20.0

const apple_template = preload("res://apple_pickup.tscn")
const strawberry_template = preload("res://strawberry_pickup.tscn")
const enemy_template = preload("res://ghost_enemy.tscn")
const dot_template = preload("res://dot.tscn")

const GAME_STATE_RUN : String = 'RUN'
const GAME_STATE_PAUSE : String = 'PAUSE'
const GAME_STATE_WIN : String = 'WIN'
const GAME_STATE_LOSE : String = 'LOSE'

var game_state = GAME_STATE_RUN

func win():
    print("You win the level!")
    $win_sound.play()
    $"../labels/win_message_panel".visible = true
    $restart_timer.start()
    pause_game(false)
    game_state = GAME_STATE_WIN

func lose():
    print("You lose the level!")
    $lose_sound.play()
    $restart_timer.start(2.0)
    pause_game(false)
    game_state = GAME_STATE_LOSE
    
func game_is_won():
    return game_state == GAME_STATE_WIN

func eat_dot():
    $"../player-char".eat()
    add_points(DOT_POINTS)
    check_dots_remaining()

func eat_power_dot():
    $"../player-char".eat_power_dot()
    add_points(POWER_DOT_POINTS)
    check_dots_remaining()

func all_dots_eaten():
    return $"../dots".get_child_count() + $"../dots_power".get_child_count() <= 1

func check_dots_remaining():
    var dot_count : int = 1000
    dot_count = $"../dots".get_child_count()
    print("Dots remaining to eat: ", dot_count - 1)
    
    if (all_dots_eaten()):
        win()

func add_points(new_points: int):
    player_points += new_points
    print("Points: %d" % player_points)
    check_points()
    
func check_points():
    if (player_points >= RESTART_THRESHOLD):
        restart()
        
func restart():
    reset_points()
    get_tree().reload_current_scene()

func reset_points():
    player_points = 0

func add_enemy():
    print("Adding enemy ...")
    spawn_ghost(enemy_template)
        
func add_strawberry():
    print("Adding strawberry ...")
    spawn_item(strawberry_template)
    
func add_apple():
    print("Adding apple ...")
    spawn_item(apple_template)

func spawn_item(item_template):
    #print("Adding another item ...", item_template.name)
    var new_item = item_template.instantiate()
    
    var new_x = randi() % MAX_SPAWN_RANGE_X * 2 - MAX_SPAWN_RANGE_X
    var new_y = randi() % MAX_SPAWN_RANGE_Y * 2 - MAX_SPAWN_RANGE_Y
    new_item.position = Vector2(new_x, new_y)
    
    #new_apple.add_to_group('all_apples')
    #add_child(new_apple)
    call_deferred("add_child", new_item)

func spawn_ghost(template_to_use):
    #print("Adding another item ...", item_template.name)
    var new_enemy = template_to_use.instantiate()
    
    var new_x = randi() % MAX_ENEMY_SPAWN_RANGE_X * 2 - MAX_ENEMY_SPAWN_RANGE_X + SPAWN_BIAS_X
    var new_y = randi() % MAX_ENEMY_SPAWN_RANGE_Y * 2 - MAX_ENEMY_SPAWN_RANGE_Y + SPAWN_BIAS_Y
    new_enemy.position = Vector2(new_x, new_y)
    
    #new_apple.add_to_group('all_apples')
    #add_child(new_apple)
    $"../enemies".call_deferred("add_child", new_enemy)
    
    
func respawn_ghost(phase : String):
    print("GM respawning ghost ... {type}".format({"type": phase}))
    print("    ... but waiting first for %d seconds" % RESPAWN_TIME_SEC)
    
    await get_tree().create_timer(RESPAWN_TIME_SEC).timeout
    
    var new_enemy = enemy_template.instantiate()
    
    new_enemy.phase = phase
    new_enemy.position = get_starting_position(new_enemy.phase)
    $"../enemies".call_deferred("add_child", new_enemy)

func get_starting_position(phase):
    var start_x_map : Dictionary = {
        'blinky': -3 * GHOST_RADIUS,
        'inky': -1 * GHOST_RADIUS,
        'pinky': 1 * GHOST_RADIUS,
        'clyde': 3 * GHOST_RADIUS
    }
    return Vector2(start_x_map[phase], -80)

func spawn_dot(position : Vector2):
    print("Adding another dot at position: ", position)
    var new_dot = dot_template.instantiate()
    new_dot.position = position
    %dots.call_deferred("add_child", new_dot)

func generate_new_loot():
    for x in range(STARTING_APPLES):
        add_apple()

    for x in range(STARTING_STRAWBERRIES):
        add_strawberry()

func transform_ghosts():
    print("Transforming ghosts to vulnerable state ...")
    for ghost in $"../enemies".get_children():
        print(ghost.name, " transforming to vuln state!")
        ghost.start_vulnerable()
    
func detect_platform():
    platform = OS.get_name()
    print("Platform: ", platform)
    platform_is_mobile = platform in MOBILE_PLATFORMS

func set_ui():
    $ui/quit_button.visible = platform_is_mobile
    
func quit():
    get_tree().quit()

func pause_game(visible_message : bool = true):
    print("Pausing game ...")
    for enemy in $"../enemies".get_children():
        enemy.freeze()
    $"../player-char".freeze(true)
    if visible_message:
        $"../labels/pause_message".visible = true
    game_state = GAME_STATE_PAUSE
        
func unpause_game():
    print("Unpausing game ...")
    for enemy in $"../enemies".get_children():
        enemy.unfreeze()
    $"../player-char".unfreeze()
    $"../labels/pause_message".visible = false 
    game_state = GAME_STATE_RUN

func is_paused():
    return game_state == GAME_STATE_PAUSE

func toggle_pause():
    if  is_paused():
        unpause_game()
    else: 
        pause_game()

# Called when the node enters the scene tree for the first time.
func _ready():
    print("Game manager ready!")
    detect_platform()
    set_ui()
    generate_new_loot()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass

func _on_spawntimer_timeout(phase):
    pass
    print("spawntimer_timeout -- ", phase)
    #respawn_ghost(phase)

func _on_restart_timer_timeout():
    restart()

func _on_path_follower_make_dot(new_position : Vector2):
    spawn_dot(new_position)
