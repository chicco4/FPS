extends CharacterBody3D

@onready var main_camera = $MainCamera

var camera_rotation = Vector2(0,0)
var mouse_sensitivity = 0.005

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):	
	if event is InputEventMouseMotion:
		var mouse_event = event.relative * mouse_sensitivity
		camera_look(mouse_event)
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			get_tree().quit()

func camera_look(movement: Vector2):
	camera_rotation += movement
	camera_rotation.y = clamp(camera_rotation.y, -1.5, 1.5)
	
	transform.basis = Basis()
	main_camera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0), -camera_rotation.x) # first rotate y
	main_camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y) # then rotate x


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		#if !audio_stream_player.is_playing():
			#audio_stream_player.play()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		#audio_stream_player.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

