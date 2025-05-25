extends CharacterBody2D

# Velocidad del personaje
@export var speed := 180
@export var gravity := 850
@export var jump_force := -300

# Referencia al AnimatedSprite2D
@onready var sprite := $AnimatedSprite2D

func _physics_process(delta):
	var input_vector := Vector2.ZERO

	# Movimiento horizontal
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = input_vector.x * speed

	# Aplicar gravedad si no estamos en el suelo
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Salto
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force

	# Mover al personaje
	move_and_slide()

	# Animaciones
	if input_vector.x != 0:
		sprite.play("walk")
		sprite.flip_h = input_vector.x < 0
	else:
		sprite.play("idle")
