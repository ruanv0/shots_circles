extends CharacterBody2D


var speed = 21000
var balas_usadas = [false, false, false]
var last_attack = ""


func preparar(cor, user_name):
	var cores_pt = ["amarelo", "azul", "banana",
					"branco", "caqui", "ciano",
					"cinza", "coral", "laranja",
					"limao", "marrom", "preto",
					"rosa_claro", "rosa_escuro", "roxo",
					"verde", "vermelho", "vinho"]
	$circulo.texture = load("res://circulos/circulo_" + cores_pt[cor] + ".png")
	$name.text = user_name
	if cor in [0, 2, 3, 4, 5, 7, 9, 12]:
	# Circulos claros com textos escuros
	# O texto é branco por padrão
		$name.add_theme_color_override("font_color", Color8(0, 0, 0))
	if len(user_name) > 7:
		$name.add_theme_font_size_override("font_size", 50 / float(len(user_name)) * 7)
	else:
		$name.position.x += 28 * (7 - len(user_name)) / 2.0
	$camera.visible = is_multiplayer_authority()
	$joystick_andar.visible = is_multiplayer_authority()
	$joystick_atirar.visible = is_multiplayer_authority()
	$tempo.visible = is_multiplayer_authority()


func _enter_tree():
	var authority_name = str(name).replace("player", "")
	set_multiplayer_authority(authority_name.to_int())


func _ready():
	preparar(get_meta("cor"), get_meta("user_name"))
	if is_multiplayer_authority():
		$camera.make_current()


func ajustar_tiro():
	var num_bala = balas_usadas.find(false)
	get_node("bala" + str(num_bala)).usar()
	balas_usadas[num_bala] = true


func desativar_bala(num: String):
	balas_usadas[int(num)] = false


func andar(delta):
	var goto = $joystick_andar.go_to
	var angle = $joystick_atirar.angle
	var radius = $joystick_atirar.radius
	# $arma e $mira devem ter a mesma rotação e a mesma visibilidade
	if angle != 0:
		$arma.global_position = Vector2(global_position.x + 640 + sin(angle) * radius * 1.3,
										global_position.y + 360 - cos(angle) * radius * 1.3)
		$arma.rotation = angle
		$mira.global_position = Vector2(global_position.x + 640 + sin(angle) * radius * 3.2,
										global_position.y + 360 - cos(angle) * radius * 3.2)
		$mira.rotation = angle
		# A visilibidade de $arma e $mira devem ser iguais
		if not $arma.visible:
			$arma.visible = true
			$mira.visible = true
	elif angle == 0:
		$arma.rotation = 0
		$mira.rotation = 0
	# A visilibidade de $arma e $mira devem ser iguais
		if $arma.visible:
			$arma.visible = false
			$mira.visible = false
	if goto.x == 0 and goto.y == 0 and not (velocity.x == 0 and velocity.y == 0):
		# Parar de andar mudando a velocidade
		velocity = Vector2(0, 0)
	else:
		velocity = Vector2(goto.x * speed * delta,
						   goto.y * speed * delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_multiplayer_authority():
		var tempo = floori($"../game_timer".time_left)
		if $tempo.text != str(tempo):
			if floori(tempo / 60.0) >= 10:
				if tempo % 60 >= 10:
					$tempo.text = "Tempo: " + str(floori(tempo / 60.0)) + ":" + str(tempo % 60)
				elif tempo % 60 < 10:
					$tempo.text = "Tempo: " + str(floori(tempo / 60.0)) + ":0" + str(tempo % 60)
			elif floori(tempo / 60.0) < 10:
				if tempo % 60 >= 10:
					$tempo.text = "Tempo: 0" + str(floori(tempo / 60.0)) + ":" + str(tempo % 60)
				elif tempo % 60 < 10:
					$tempo.text = "Tempo: 0" + str(floori(tempo / 60.0)) + ":0" + str(tempo % 60)
		andar(delta)
		# Mover com a variável velocity
		move_and_slide()
		update_data.rpc(position, $arma.visible, $arma.rotation, $arma.position)
		print(position)


@rpc("call_remote", "unreliable")
func update_data(authority_position: Vector2, arma_visibility: bool, arma_rotation: float, arma_position: Vector2):
	position = authority_position
	$arma.visible = arma_visibility
	$arma.rotation = arma_rotation
	$arma.position = arma_position


@rpc("call_local", "any_peer")
func hurt(attacker_name: String):
	last_attack = attacker_name
	$saude.value -= 1
	$timer1.start()
	if $saude.value == 0:
		if is_multiplayer_authority():
			count_kill.rpc(last_attack)
			$players_list.clear()
			$kills_list.clear()
			$"../".sort_kills()
			for i in $"../".kills:
				$players_list.add_item(i[0])
				$kills_list.add_item(str(i[1]))
			$players_list.visible = 1
			$kills_list.visible = 1
			$fundo.visible = 1
			$renascer.visible = 1
			$renascer/timer.start()
			$camera.zoom = Vector2(0.5, 0.5)
			$joystick_atirar.visible = 0
			$joystick_andar.position = Vector2(-220, 694)
			$joystick_andar.scale = Vector2(1.4, 1.4)
		$collision_shape.set_deferred("disabled", 1)
		$circulo.visible = 0
		$arma.visible = 0
		$saude.visible = 0
		$name.visible = 0


@rpc("call_local")
func count_kill(last_attack_: String):
	for i in range(0, len($"../".kills)):
		if $"../".kills[i][2] == last_attack_:
			$"../".kills[i][1] += 1
			break


func terminar():
	$collision_shape.set_deferred("disabled", 1)
	if is_multiplayer_authority():
		$players_list.visible = 1
		$kills_list.visible = 1
		$players_list.clear()
		$kills_list.clear()
		$"..".sort_kills()
		for i in $"..".kills:
			$players_list.add_item(i[0])
			$kills_list.add_item(str(i[1]))
		$fundo.visible = 1
		$camera.zoom = Vector2(0.5, 0.5)
		$joystick_atirar.visible = 0
		$joystick_andar.position = Vector2(-220, 694)
		$joystick_andar.scale = Vector2(1.4, 1.4)
		$terminando.visible = 1
		$terminando/finish_timer.start()
		$tempo.visible = 0


func _on_timer_0_timeout():
	# O $timer0 é o tempo entre as adições de saúde
	# O $timer1 é o tempo após um tiro que tardaria as adições de saúde
	if $timer1.is_stopped() and $saude.value < $saude.max_value:
		$saude.value += 1
	$timer0.start()


@rpc("call_local")
func terminar_():
	$"..".queue_free()
	$"../../multiplayer_menu".visible = true


func _on_finish_timer_timeout():
	# O host tem id 1
	if multiplayer.get_unique_id() == 1:
		terminar_.rpc()
