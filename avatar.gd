extends Node2D


var botoes = []
var textos = []
var textos_pt = ["Amarelo", "Azul", "Banana",
				 "Branco", "Cáqui", "Ciano",
				 "Cinza", "Coral", "Laranja",
				 "Limão", "Marrom", "Preto",
				 "Rosa Claro", "Rosa Escuro", "Roxo",
				 "Verde", "Vermelho", "Vinho"]
var colunas_px = []
var back_pressed = -1


func select(num_cor: int) -> void:
	var y = 720 - 190 - 30 # == 500
	$select.scale = Vector2(colunas_px[floor(num_cor / 5.0)] + 100,
							100)
	var x_ = 0
	for j in range(0, floor(num_cor / 5.0)):
		x_ += colunas_px[j] + 100
	$select.global_position = Vector2(50 + x_,
									  190 + y / 5.0 * (num_cor % 5))
	if player_info.cor != num_cor:
		player_info.cor = num_cor
		player_info.save()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$name_text.text = player_info.user_name
	for i in get_children():
		if i.name in ["select", "avatar", "escolha", "back", "name_text", "name"]:
			continue
		if i is Sprite2D:
			botoes.append(i)
		elif i is Label:
			textos.append(i)
	var textos_pt_pixels = [162, 81, 145,
							135, 109, 108,
							103, 100, 144,
							118, 156, 105,
							197, 230, 96,
							113, 186, 110]
	var largest_px = -1
	for i in range(0, len(textos_pt_pixels)):
		if textos_pt_pixels[i] > largest_px:
			largest_px = textos_pt_pixels[i]
		if (i + 1) % 5 == 0 or (i + 1) == len(textos_pt_pixels):
			colunas_px.append(largest_px)
			largest_px = -1
	var x = 1280 - 100 # 1280 - 100 == 1060
	var y = 720 - 190 - 30 # 720 - 190 - 30 == 500
	for i in range(0, len(botoes)):
		var x_ = 0
		botoes[i].global_position.y = 190 + y / 5.0 * (i % 5) + 5
		for j in range(0, floor(i / 5.0)):
			x_ += colunas_px[j] + 100
		botoes[i].global_position.x = 50 + x_ + 5
		textos[i].global_position.y = 190 + y / 5.0 * (i % 5) + 25
		textos[i].global_position.x = 50 + x_ + 100
	select(player_info.cor)


func _input(event) -> void:
	if visible and event is InputEventScreenTouch and not event.pressed:
		var coluna = -1
		var x = 50
		for i in range(0, len(colunas_px)):
			x += colunas_px[i] + 100
			if event.position.x < 50:
				break
			elif event.position.x < x:
				coluna = i
				break
		var linha = -1
		var y = 190
		if coluna == 3:
			for i in range(0, 3):
				y += 100
				if event.position.y < 190:
					break
				elif event.position.y < y:
					linha = i
					break
		elif coluna < 3:
			for i in range(0, 5):
				y += 100
				if event.position.y < 190:
					break
				elif event.position.y < y:
					linha = i
					break
		if linha != -1 and coluna != -1:
			select(5 * coluna + linha)
		if event.position.x > 50 and event.position.x < 140 and event.position.y > 40 and event.position.y < 130:
			call_deferred("add_sibling", load("res://hub.tscn").instantiate())
			queue_free()
		elif event.index == back_pressed:
			$back.texture = load("res://back_button.png")
			back_pressed = -1
		elif event is InputEventScreenTouch and event.pressed:
			if event.position.x > 50 and event.position.x < 140 and event.position.y > 40 and event.position.y < 130:
				$back.texture = load("res://back_button_pressed.png")
				back_pressed = event.index


func _on_name_text_text_changed(new_text) -> void:
	player_info.user_name = new_text
	player_info.save()
