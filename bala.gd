extends CharacterBody2D


var speed = 2000
var goto = Vector2(0, 0)


func _ready():
  scale = Vector2(0.25, 0.25)
  # self.scale deve ser igual a $"../character".scale ns mapas


func usar():
  visible = true
  goto = $"../joystick_atirar".go_to
  var angle = $"../joystick_atirar".angle
  var radius = $"../joystick_atirar".radius
  global_position = Vector2($"../".global_position.x + 640 + sin(angle) * (radius + 100),
                            $"../".global_position.y + 360 - cos(angle) * (radius + 100))
  rotation = angle
  velocity = goto * speed
  $timer.start()


func parar():
  $timer.stop()
  visible = false
  velocity = Vector2(0, 0)
  $"../".desativar_bala(str(name)[4])


func _physics_process(_delta):
  if $timer.is_stopped() and visible:
    #$"../multiplayer_synchronizer".replication_config.remove_property(name + ":position")
    #queue_free()
    visible = false
    velocity = Vector2(0, 0)
    $"../".desativar_bala(str(name)[4])
  move_and_slide()


func _on_area_2d_body_entered(body):
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



func _on_area_2d_2_body_entered(body):
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
