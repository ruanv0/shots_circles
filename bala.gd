extends CharacterBody2D


var speed = 2000
var goto


func _ready():
  scale = Vector2(0.25, 0.25)
  # self.scale deve ser igual a $"../character".scale ns mapas
  #$"../multiplayer_synchronizer".replication_config.add_property(name + ":position")
  #print($"../multiplayer_synchronizer".replication_config.get_properties())
  goto = $"../joystick_atirar".go_to
  var angle = $"../joystick_atirar".angle
  var radius = $"../joystick_atirar".radius
  global_position = Vector2($"../".global_position.x + 640 + sin(angle) * radius,
                            $"../".global_position.y + 360 - cos(angle) * radius)
  rotation = angle
  velocity = goto * speed
  $timer.start()


func _physics_process(_delta):
  if $timer.is_stopped():
    #$"../multiplayer_synchronizer".replication_config.remove_property(name + ":position")
    queue_free()
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
