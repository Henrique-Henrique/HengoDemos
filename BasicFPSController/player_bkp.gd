extends CharacterBody3D

var _STATE_CONTROLLER = HengoStateController.new()

const SPEED = 5
const SPRINT_SPEED = 10

var speed = SPEED

const JUMP_VELOCITY = 9.0
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


func _init() -> void:
	_STATE_CONTROLLER.set_states({
		idle = Idle.new(self),
		walking = Walking.new(self),
		jumping = Jumping.new(self),
		running = Running.new(self),
	})


func go_to_event(_obj_ref: Node, _state_name: StringName) -> void:
	_obj_ref._STATE_CONTROLLER.change_state(_state_name)


func _ready() -> void:
	if not _STATE_CONTROLLER.current_state:
		EngineDebugger.send_message('hengo:debug_state', [2])
		_STATE_CONTROLLER.change_state("idle")
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	_STATE_CONTROLLER.static_process(delta)


func _physics_process(delta: float) -> void:
	_STATE_CONTROLLER.static_physics_process(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

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

	if velocity.length() == 0:
		_STATE_CONTROLLER.change_state('idle')

	move_and_slide()

	if Input.is_action_just_pressed('jump') and is_on_floor():
		_STATE_CONTROLLER.change_state('jumping')

	if Input.is_action_just_pressed('l_mouse'):
		_pick()

	if Input.is_action_just_released('l_mouse'):
		picked_obj = null

	if Input.is_action_just_pressed('r_mouse'):
		if picked_obj:
			picked_obj.linear_velocity = hand.global_transform.basis.z * -40
			picked_obj = null

	if picked_obj:
		var a = picked_obj.global_transform.origin
		var b = hand.global_transform.origin

		(picked_obj as RigidBody3D).linear_velocity = (b - a) * PULL_POWER

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSIBILITY)
		camera.rotate_x(-event.relative.y * SENSIBILITY)

# Signals Callables
class Idle extends HengoState:
	func update(_delta: float) -> void:
		if _ref.velocity.length() > 0 and _ref.is_on_floor():
			_ref._STATE_CONTROLLER.change_state('walking')


class Walking extends HengoState:
	func enter() -> void:
		_ref.speed = SPEED
	
	func update(_delta: float) -> void:
		if Input.is_action_pressed('run'):
			_ref._STATE_CONTROLLER.change_state('running')
		
		if _ref.velocity.length() == 0:
			_ref._STATE_CONTROLLER.change_state('idle')


class Running extends HengoState:
	func enter() -> void:
		_ref.speed = SPRINT_SPEED
	
	func update(_delta: float) -> void:
		if Input.is_action_just_released('run'):
			_ref._STATE_CONTROLLER.change_state('walking')
	

class Jumping extends HengoState:
	func enter() -> void:
		_ref.velocity.y = JUMP_VELOCITY

	func update(_delta: float) -> void:
		if _ref.velocity.y == 0:
			_ref._STATE_CONTROLLER.change_state('idle')
	
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

func _headpop(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _pick() -> void:
	var collider = ray.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_obj = collider