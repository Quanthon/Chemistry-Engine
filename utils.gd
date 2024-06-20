class_name Utils
extends Object

static func get_all_children(parent: Node) -> Array[Node]:
  var result : Array[Node]
  for child in parent.get_children():
    result.append(child)
    result.append_array(get_all_children(child))
  return result

static func get_property_names(obj: Object) -> Array[String]:
  var result: Array[String]
  for data in obj.get_property_list():
    var usage = data["usage"]
    if usage >> 12 == 1:
      result.append(data["name"])
  return result

static func get_files(folder_path: String) -> Array[String]:
  var dir = DirAccess.open(folder_path)
  var result : Array[String]
  if dir:
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
      if dir.current_is_dir():
        pass
      else:
        result.append(file_name)
      file_name = dir.get_next()
  else:
    print("An error occurred when trying to access the path.")
  return result

static func get_all_files(folder_path: String, prefix := "") -> Array[String]:
  var dir = DirAccess.open(folder_path + "/" + prefix)
  var result : Array[String]
  if dir:
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
      var name = prefix + file_name
      if dir.current_is_dir():
        result.append_array(get_all_files(folder_path, file_name + "/"))
      else:
        result.append(name)
      file_name = dir.get_next()
  else:
    print("An error occurred when trying to access the path.")
  return result

static func compare_update(nodes: Array, data: Array, compare: Callable, new: Callable, remove: Callable):
  var flags = nodes.map(func(__): false)
  var _nodes = nodes.duplicate()
  for i in data.size():
    var d = data[i]
    var flag := false
    # TODO: Optimize
    for j in _nodes.size():
      var n = _nodes[j]
      if compare.call(n, d):
        flags[j] = true
        flag = true
        break;
    if not flag:
      new.call(d)
  var j = 0
  for i in _nodes.size():
    if not flags[i]:
      var n = _nodes[i]
      remove.call(n)
      j+=1

static  func magnitude(level: int) -> int:
  const list = [1, 2, 5]
  return list[level % list.size()] * 10 ** floor(level * 1. / list.size())