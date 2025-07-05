extends CharacterBody2D


var speed = 21000
var balas_usadas = [false, false, false]
var last_attack = ""


func preparar() -> void:
	var cores_pt = ["amarelo", "azul", "banana",
					"branco", "caqui", "ciano",
					"cinza", "coral", "laranja",
					"limao", "marrom", "preto",
					"rosa_claro", "rosa_escuro", "roxo",
					"verde", "vermelho", "vinho"]
	$circulo.texture = load("res://circulos/circulo_" + cores_pt[get_meta("cor")] + ".png")
	$name.text = get_meta("user_name")
	if get_meta("cor") in [0, 2, 3, 4, 5, 7, 9, 12]:
	# Circulos claros com textos escuros
	# O texto é branco por padrão
		$name.add_theme_color_override("font_color", Color8(0, 0, 0))
	if len(get_meta("user_name")) > 7:
		$name.add_theme_font_size_override("font_size", 50 / float(len(get_meta("user_name"))) * 7)
		await($name.minimum_size_changed)
	$name.reset_size()
	$name.position.x = 640 - $name.size.x / 2
	if player_info.my_multiplayer_id == int(name.replace("player", "")):
		$camera.visible = true
		$joystick_andar.visible = true
		$joystick_atirar.visible = true
		$tempo.visible = true
		$mapa.visible = true
	else:
		$camera.visible = false
		$joystick_andar.visible = false
		$joystick_atirar.visible = false
		$tempo.visible = false
		$mapa.visible = false


func _enter_tree() -> void:
	set_multiplayer_authority(int(name.replace("player", "")))


func _ready() -> void:
	preparar()
	if player_info.my_multiplayer_id == int(name.replace("player", "")):
		$camera.make_current()


func ajustar_tiro() -> void:
	var num_bala = balas_usadas.find(false)
	get_node("bala" + str(num_bala)).usar()
	balas_usadas[num_bala] = true


func desativar_bala(num: String) -> void:
	balas_usadas[int(num)] = false


func andar(delta) -> void:
	var goto = $joystick_andar.go_to
	var angle = $joystick_atirar.angle
	# $arma e $mira devem ter a mesma rotação e a mesma visibilidade
	if angle != 0:
		$arma.global_position = Vector2(global_position.x + 640 + sin(angle) * ($collision_shape.shape.radius + 20),
										global_position.y + 360 - cos(angle) * ($collision_shape.shape.radius + 20))
		$arma.rotation = angle
		$mira.global_position = Vector2(global_position.x + 640 + sin(angle) * ($collision_shape.shape.radius + 240),
										global_position.y + 360 - cos(angle) * ($collision_shape.shape.radius + 240))
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
func _physics_process(delta) -> void:
	if player_info.my_multiplayer_id == int(name.replace("player", "")):
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
		update_data.rpc(global_position, $arma.visible, $arma.rotation, $arma.position)
		#print(position)
		#Vector2(-3000, -3300)
		#Vector2(3600, 3300)
		
		#Vector2(-94.5, -94.5)
		#Vector2(94.5, 94.5)
		
		
		$mapa/ponto.position.x = (((global_position.x + 3000) / 6600) * 378 - 160)
		$mapa/ponto.position.y = (((global_position.y + 3300) / 6600) * 378 - 160)
		#print($mapa/ponto.position)
		


@rpc("call_remote", "unreliable")
func update_data(authority_position: Vector2, arma_visibility: bool, arma_rotation: float, arma_position: Vector2) -> void:
	global_position = authority_position
	$arma.visible = arma_visibility
	$arma.rotation = arma_rotation
	$arma.position = arma_position


@rpc("call_local", "any_peer")
func hurt(attacker_name: String) -> void:
	last_attack = attacker_name
	$saude.value -= 1
	$timer1.start()
	if $saude.value == 0:
		if player_info.my_multiplayer_id == int(name.replace("player", "")):
			count_kill.rpc(last_attack)
			$players_list.clear()
			$kills_list.clear()
			$"../".sort_kills()
			for item in $"../".kills:
				$players_list.add_item(item[0])
				$kills_list.add_item(str(item[1]))
			$players_list.visible = true
			$kills_list.visible = true
			$fundo.visible = true
			$renascer.visible = true
			$renascer/timer.start()
			$camera.zoom = Vector2(0.5, 0.5)
			$joystick_atirar.visible = false
			$joystick_andar.position = Vector2(-220, 694)
			$joystick_andar.scale = Vector2(1.4, 1.4)
		$collision_shape.set_deferred("disabled", 1)
		$circulo.visible = false
		$arma.visible = false
		$saude.visible = false
		$name.visible = false


@rpc("call_local")
func count_kill(last_attack_: String) -> void:
	for i in range(0, len($"../".kills)):
		if $"../".kills[i][2] == last_attack_:
			$"../".kills[i][1] += 1
			break


func disable_player() -> void:
	visible = false


func terminar() -> void:
	$collision_shape.set_deferred("disabled", 1)
	if player_info.my_multiplayer_id == int(name.replace("player", "")):
		$players_list.visible = true
		$kills_list.visible = true
		$players_list.clear()
		$kills_list.clear()
		$"..".sort_kills()
		for item in $"..".kills:
			$players_list.add_item(item[0])
			$kills_list.add_item(str(item[1]))
		$fundo.visible = true
		$camera.zoom = Vector2(0.5, 0.5)
		$joystick_atirar.visible = false
		$joystick_andar.position = Vector2(-220, 694)
		$joystick_andar.scale = Vector2(1.4, 1.4)
		$terminando.visible = true
		$terminando/finish_timer.start()
		$tempo.visible = false
		$mapa.visible = false


func _on_timer_0_timeout() -> void:
	# O $timer0 é o tempo entre as adições de saúde
	# O $timer1 é o tempo após um tiro que tardaria as adições de saúde
	if $timer1.is_stopped() and $saude.value < $saude.max_value:
		$saude.value += 1
	$timer0.start()


@rpc("call_local")
func terminar_() -> void:
	$"..".queue_free()
	$"../../multiplayer_menu".visible = true


func _on_finish_timer_timeout() -> void:
	# O host tem id 1
	if multiplayer.get_unique_id() == 1:
		terminar_.rpc()
