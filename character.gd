extends CharacterBody2D


var speed = 21000
var andando = false
var balas_usadas = [false, false, false]


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
  $camera.visible = is_multiplayer_authority()
  $joystick_andar.visible = is_multiplayer_authority()
  $joystick_atirar.visible = is_multiplayer_authority()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  if is_multiplayer_authority():
    var goto = $joystick_andar.go_to
    var angle = $joystick_atirar.angle
    var radius = $joystick_atirar.radius
    # $arma e $mira devem ter a mesma rotação e a mesma visibilidade
    if angle != 0:
      $arma.global_position = Vector2(global_position.x + 640 + sin(angle) * radius * 1.2,
                                      global_position.y + 360 - cos(angle) * radius * 1.2)
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
    $saude.value -= 1
    body.parar()
    $timer1.start()


func _on_timer_0_timeout():
  # O $timer0 é o tempo entre as adições de saúde
  # O $timer1 é o tempo após um tiro que tardaria as adições de saúde
  if $timer1.is_stopped() and $saude.value < $saude.max_value:
    $saude.value += 1
  $timer0.start()
