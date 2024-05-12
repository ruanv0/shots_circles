extends Sprite2D

var touched = []
var first_touch
var old_position
var radius = 150 * scale.x # Deve ser igual a scale.y
var go_to = Vector2(0, 0)
var angle = 0


func _ready():
  old_position = global_position
  radius *= scale.x # scale.x e scale.y devem ser iguais


func _input(event):
  if event is InputEventScreenTouch:
    var distance = event.position.distance_to(old_position)
    if event.pressed:
      if distance <= radius && distance >= radius * -1:
        touched.append(event.index)
    elif not event.pressed:
      touched.erase(event.index)
      $small_circle.position = Vector2(0, 0)
      go_to = Vector2(0, 0)
      angle = 0
    
    first_touch = -1
    if len(touched) != 0:
      first_touch = touched[0]
  elif event is InputEventScreenDrag && event.index == first_touch:
    if event.position.distance_to(old_position) > radius:
      trocar_posicao(old_position - event.position, true)
    else:
      trocar_posicao(old_position - event.position, false)


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
