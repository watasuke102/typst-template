#let image_clip(path, value) = {
  let insets = if type(value) == int {
    (rest: value)
  } else {
    assert(type(value) == dictionary, message: "image_clip: value must be an int or dictionary")
    value
  }
  for (key, amount) in insets {
    assert(key in ("left", "top", "right", "bottom", "x", "y", "rest"),
      message: "image_clip: unknown inset key " + key)
    assert(type(amount) == int, message: "image_clip: " + key + " must be an int (pixels)")
    assert(amount >= 0 and amount <= 4294967295,
      message: "image_clip: " + key + " must be between 0 and 4294967295 pixels")
  }
  let rest = insets.at("rest", default: 0)
  let x = insets.at("x", default: rest)
  let y = insets.at("y", default: rest)
  let sides = (
    insets.at("left", default: x),
    insets.at("top", default: y),
    insets.at("right", default: x),
    insets.at("bottom", default: y),
  )
  let encoded = sides.fold(bytes(()), (acc, side) => acc + int.to-bytes(side, size: 4, endian: "little"))
  plugin("image_clip.wasm").clip(read(path, encoding: none), encoded)
}
