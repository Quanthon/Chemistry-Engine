class_name Data

func _init(dict: Dictionary = {}):
  for key in dict:
    assert(key in self, "Key %s not found" % key)
    var value = dict[key]
    if value is Array:
      self[key].append_array(value)
    else: self[key] = value

func to_dict():
  var props = Utils.get_property_names(self)
  var dict := {}
  for prop in props:
    dict[prop] = self[prop]
  return dict

func _to_string():
  return str(to_dict())

func duplicate():
  return self.get_script().new(to_dict())
