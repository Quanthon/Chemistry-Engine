class_name Pattern
extends Resource

@export var positions : Array[Vector2i]
@export var weight := 6

func rotate(i: int) -> Pattern:
  if i == 0:
    return self
  var other = Pattern.new()
  for pos in positions:
    match i:
      1:
        other.positions.append(Vector2i(pos.y, -pos.x))
      2:
        other.positions.append(Vector2i(-pos.x, -pos.y))
      3:
        other.positions.append(Vector2i(-pos.y, pos.x))
  return other