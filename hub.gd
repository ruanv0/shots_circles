extends Node2D


var zero_map = load("res://zero.tscn")
var host
#comentario teste

func _ready():
  $host.position.x = (get_viewport_rect().size.x - 500) / 2
  $host.position.y = ((get_viewport_rect().size.y - 250) * 0.5) / 2
  $join.position.x = (get_viewport_rect().size.x - 500) / 2
  $join.position.y = ((get_viewport_rect().size.y - 250) * 1.5) / 2


func _on_host_pressed():
  host = true
  call_deferred("add_sibling", zero_map.instantiate())


func _on_join_pressed():
  host = false
  call_deferred("add_sibling", zero_map.instantiate())
