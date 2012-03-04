module "utils"

test "round the floats", ->
  expect 4

  equal 'string', typeof round(1.0, 2), 'returns a string'
  equal "1.00", round(1.0, 2), 'fixed 2 decimal digits'
  equal "1.01", round(1.0111, 2), 'round down'
  equal "1.02", round(1.0154, 2), 'round up'

