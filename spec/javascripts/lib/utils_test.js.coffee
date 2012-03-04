module "utils"

test "round the floats", ->
  expect 4

  equal 'string', typeof round(1.0, 2), 'to a string'
  equal "1.00", round(1.0, 2), 'to 2 decimal digits'
  equal "1.01", round(1.0111, 2), 'down'
  equal "1.02", round(1.0154, 2), 'up'

