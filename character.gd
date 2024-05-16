extends CharacterBody2D


var speed = 21000
var andando = false
var balas_usadas = [false, false, false]
var cor = -1

func ajustar_tiro():
  var num_bala = balas_usadas.find(false)
  get_node("bala" + str(num_bala)).usar()
  balas_usadas[num_bala] = true
  


func desativar_bala(num: String):
  balas_usadas[int(num)] = false


func _enter_tree():
  set_multiplayer_authority(name.to_int())


func _ready():
  if is_multiplayer_authority():
    $camera.make_current()
    set_meta("cor", player_info.cor)
    $name.text = player_info.user_name
    if player_info.cor in [0, 2, 3, 4, 5, 7, 9, 12]:
      # Circulos claros com textos escuros
      # O texto é branco por padrão
      $name.add_theme_color_override("font_color", Color8(0, 0, 0))
    if len(player_info.user_name) > 7:
      $name.add_theme_font_size_override("font_size", 50 / float(len(player_info.user_name)) * 7)
    else:
      $name.position.x += 28 * (7 - len(player_info.user_name)) / 2
  $camera.visible = is_multiplayer_authority()
  $joystick_andar.visible = is_multiplayer_authority()
  $joystick_atirar.visible = is_multiplayer_authority()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  if get_meta("cor") != -1 and cor == -1:
    var cores_pt = ["amarelo", "azul", "banana",
                    "branco", "caqui", "ciano",
                    "cinza", "coral", "laranja",
                    "limao", "marrom", "preto",
                    "rosa_claro", "rosa_escuro", "roxo",
                    "verde", "vermelho", "vinho"]
    $circulo.texture = load("res://circulos/circulo_" + cores_pt[get_meta("cor")] + ".png")
    cor = get_meta("cor")
  if is_multiplayer_authority():
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
    if goto.x == 0 and goto.y == 0:
      if andando:
        andando = false
        # Parar de andar mudando a velocidade
        velocity = Vector2(0, 0)
    else:
      velocity.x = goto.x * speed * delta
      velocity.y = goto.y * speed * delta
      if not andando:
        andando = true
    # Mover com a variável velocity
    move_and_slide()


func _on_area_2d_body_entered(body):
  # As balas tem nomes como "bala", "bala1", "bala2", "bala17" e outros
  # Com modos em equipe, é preciso no futuro
  # diferenciar as balas aliadas e adversárias
  if "bala" in body.name:
    body.parar()
    if is_multiplayer_authority():
      $saude.value -= 1
      $timer1.start()


func _on_timer_0_timeout():
  if is_multiplayer_authority():
    # O $timer0 é o tempo entre as adições de saúde
    # O $timer1 é o tempo após um tiro que tardaria as adições de saúde
    if $timer1.is_stopped() and $saude.value < $saude.max_value:
      $saude.value += 1
    $timer0.start()
