extends Sprite2D

var touched = []
var first_touch
var old_position
var radius = 150 * scale.x # scale.x deve ser igual a scale.y
var angle = 0
var go_to = Vector2(0, 0)


@rpc("call_local")
func _ready():
  if is_multiplayer_authority():
    old_position = global_position
    radius *= scale.x # scale.x e scale.y devem ser iguais


func _input(event):
  if is_multiplayer_authority():
    if event is InputEventScreenTouch:
      var distance = event.position.distance_to(old_position)
      if event.pressed:
        if distance <= radius && distance >= radius * -1:
          touched.append(event.index)
          trocar_posicao.rpc(old_position - event.position, true)
      elif not event.pressed && event.index in touched:
        atirar.rpc()
        touched.erase(event.index)
        $small_circle.position = Vector2(0, 0)
        go_to = Vector2(0, 0)
        angle = 0
      
      first_touch = -1
      if len(touched) != 0:
        first_touch = touched[0]
    
    elif event is InputEventScreenDrag && event.index == first_touch:
      if event.position.distance_to(old_position) > radius:
        trocar_posicao.rpc(old_position - event.position, true)
      else:
        trocar_posicao.rpc(old_position - event.position, false)


@rpc("call_local")
func trocar_posicao(position_: Vector2, so_long: bool):
  var x
  var y
  if position_.x == 0 && position_.y == 0:
    x = 0
    y = 0
  elif position_.x == 0:
    x = 0
    if position_.y < 0:
      y = -1
    else:
      y = 1
  elif position_.y == 0:
    y = 0
    if position_.x < 0:
      x = -1
    else:
      x = 1
  else:
    if position_.x < 0 && position_.y > 0:
      y = position_.y / (position_.y - position_.x)
      x = position_.x / (position_.y - position_.x)
    elif position_.x > 0 && position_.y < 0:
      y = position_.y / (position_.x - position_.y)
      x = position_.x / (position_.x - position_.y)
    elif position_.x > 0 && position_.y > 0:
      y = position_.y / (position_.x + position_.y)
      x = position_.x / (position_.x + position_.y)
    elif position_.x < 0 && position_.x < 0:
      x = -position_.x / (position_.x + position_.y)
      y = -position_.y / (position_.x + position_.y)
  go_to = Vector2(-x, -y)
  angle = 0
  if go_to.x > 0 and go_to.y != 0:
    angle = PI / 2 + go_to.y / 2 * PI
  elif go_to.x < 0 and go_to.y != 0:
    angle = -(PI / 2 + go_to.y / 2 * PI)
  elif go_to.x == 0 and go_to.y < 0:
    angle = PI
  # so_long is true when the user's finger is out the bigger circle of the joystick
  if so_long:
    $small_circle.position.x = sin(angle) * radius
    $small_circle.position.y = -cos(angle) * radius
  elif not so_long:
    $small_circle.position = Vector2(-position_.x, -position_.y)


@rpc("call_local")
func atirar():
  if $balas_bar.value > 0 and $timer2.is_stopped():
    $"../".ajustar_tiro()
    $balas_bar.value -= 1
    $timer1.start()
    $timer2.start()
    $"../timer1".start()


func _on_timer_0_timeout():
  # O $timer0 é o tempo entre as recargas das balas
  # O $timer1 é o tempo após um tiro que tardaria as recargas das balas
  # Para ser mais justo entre os diferentes dispositivos
  # e evitar muitos tiros em pouco tempo,
  # o $timer2 é um tempo que começa após um tiro que,
  # enquanto não terminar, o usuário não poderá atirar
  if $balas_bar.value < $balas_bar.max_value and $timer1.is_stopped():
    $balas_bar.value += 1
  $timer0.start()
