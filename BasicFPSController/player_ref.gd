extends CharacterBody3D


const SPEED = 5
const SPRINT_SPEED = 10

var speed = SPEED

const JUMP_VELOCITY = 5.0
const SENSIBILITY = 0.005

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const PULL_POWER = 8

var t_bob = 0.0
var picked_obj: RigidBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var hand: Marker3D = $Head/Camera3D/Hand
@onready var ray: RayCast3D = $Head/Camera3D/Ray

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSIBILITY)
		camera.rotate_x(-event.relative.y * SENSIBILITY)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed('run'):
		speed = SPRINT_SPEED
	else:
		speed = SPEED

	if Input.is_action_just_pressed('l_mouse'):
		_pick()

	if Input.is_action_just_released('l_mouse'):
		picked_obj = null

	if Input.is_action_just_pressed('r_mouse'):
		if picked_obj:
			picked_obj.linear_velocity = hand.global_transform.basis.z * -40
			picked_obj = null


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headpop(t_bob)

	if picked_obj:
		var a = picked_obj.global_transform.origin
		var b = hand.global_transform.origin

		(picked_obj as RigidBody3D).linear_velocity = (b - a) * PULL_POWER

	move_and_slide()


func _headpop(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _pick() -> void:
	var collider = ray.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_obj = collider