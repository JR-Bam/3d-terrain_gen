extends CharacterBody3D

@export var look_sensitivity: float = 0.5
var vertical_look_limit: float = 90

@export var speed: int = 10
var horizontal_velocity: Vector3 = Vector3.ZERO
@export var acceleration: int = 3

var gravity: float = -9.81
var vertical_velocity: Vector3 = Vector3.ZERO
@export var jump_strength: int = 10

@export var no_gravity: bool = false;

var ground = []

@onready var head: Node3D = $Head


func _input(event: InputEvent):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * look_sensitivity)
		head.rotate_x(deg_to_rad(-event.relative.y) * look_sensitivity)
		head.rotation_degrees.x = clamp(
			head.rotation_degrees.x,
			-vertical_look_limit,
			vertical_look_limit
		)


func _physics_process(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"): direction -= global_transform.basis.z
	if Input.is_action_pressed("move_backward"): direction += global_transform.basis.z
	if Input.is_action_pressed("move_left"): direction -= global_transform.basis.x
	if Input.is_action_pressed("move_right"): direction += global_transform.basis.x
	
	horizontal_velocity = horizontal_velocity.lerp(speed * direction.normalized(), delta * acceleration)
	
	if !no_gravity:
		if ground.size():
			if vertical_velocity.y < 0:
				vertical_velocity.y = 0
			if Input.is_action_just_pressed("jump"):
				vertical_velocity.y = jump_strength 
		else:
			vertical_velocity.y += gravity * delta
	
	velocity = horizontal_velocity + vertical_velocity
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body == self:
		ground.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	ground.remove_at(ground.find(body))
