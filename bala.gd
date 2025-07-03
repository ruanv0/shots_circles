extends CharacterBody2D


var speed = 2000
var goto = Vector2(0, 0)


func _ready() -> void:
	scale = Vector2(0.25, 0.25)
	# self.scale deve ser igual a $"../character".scale ns mapas


func usar() -> void:
	visible = true
	$CollisionShape2D.disabled = false
	goto = $"../joystick_atirar".go_to
	var angle = $"../joystick_atirar".angle
	var radius = $"../joystick_atirar".radius
	global_position = Vector2($"../".global_position.x + 640 + sin(angle) * (radius + 100),
							  $"../".global_position.y + 360 - cos(angle) * (radius + 100))
	rotation = angle
	velocity = goto * speed
	$timer.start()
	if is_multiplayer_authority():
		update_data.rpc(visible, global_position)


@rpc("call_local")
func parar() -> void:
	$timer.stop()
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	velocity = Vector2(0, 0)
	$"../".desativar_bala(str(name)[4])
	if is_multiplayer_authority():
		update_data.rpc(visible, global_position)


func _physics_process(_delta) -> void:
	if is_multiplayer_authority() and not (velocity.x == 0 and velocity.y == 0):
		update_data.rpc(visible, global_position)
		move_and_slide()


@rpc("call_remote", "unreliable")
func update_data(visible_: bool, pos: Vector2) -> void:
	visible = visible_
	$CollisionShape2D.disabled = not visible
	global_position = pos


func _on_area_2d_body_entered(body) -> void:
	if body.name == "TileMap":
		if rotation >= 0 and rotation <= PI / 2:
			goto.x *= -1
		elif rotation >= PI / 2 and rotation <= PI:
			goto.y *= -1
		elif rotation <= -PI / 2 and rotation >= -PI:
			goto.x *= -1
		elif rotation <= 0 and rotation >= -PI / 2:
			goto.y *= -1
		velocity = goto * speed
		rotation = - rotation


func _on_area_2d_2_body_entered(body) -> void:
	if body.name == "TileMap":
		if rotation >= 0 and rotation <= PI / 2:
			goto.y *= -1
		elif rotation >= PI / 2 and rotation <= PI:
			goto.x *= -1
		elif rotation <= -PI / 2 and rotation >= -PI:
			goto.y *= -1
		elif rotation <= 0 and rotation >= -PI / 2:
			goto.x *= -1
		velocity = goto * speed
		rotation = - rotation


func _on_area_2d_3_body_entered(body) -> void:
	if "player" in body.name and $"..".name != body.name and is_multiplayer_authority() and visible:
		body.hurt.rpc($"../".name)
		parar.rpc()


func _on_timer_timeout() -> void:
	if visible:
		visible = false
		$CollisionShape2D.disabled = true
		velocity = Vector2(0, 0)
		$"..".desativar_bala(str(name)[4])
