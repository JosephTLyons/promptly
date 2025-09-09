import gleeunit/should
import promptly
import promptly/utils

pub fn float_test() {
  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "Dog"
      1 -> "1"
      2 -> "0.0"
      3 -> "3.14"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.as_float(fn(_) { "Could not parse to Float!" })
  |> promptly.prompt(utils.default_formatter("Give me any float: "))
  |> should.equal(0.0)
}

pub fn float_with_validation_test() {
  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "Dog"
      1 -> "1"
      2 -> "0.0"
      3 -> "3.14"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.as_float(fn(_) { "Could not parse to Float!" })
  |> promptly.with_validator(fn(x) {
    case x == 0.0 {
      True -> Error("Wasn't a non-zero float!")
      False -> Ok(x)
    }
  })
  |> promptly.prompt(utils.default_formatter("Give me any non-zero float: "))
  |> should.equal(3.14)
}
