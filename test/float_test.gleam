import gleeunit/should
import promptly
import promptly/utils.{default_formatter, result_returning_function}

pub fn float_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_float(fn(_) { "Could not parse to Float." })
  |> promptly.prompt(default_formatter("Give me any float: "))
  |> should.equal(0.0)
}

pub fn float_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_float(fn(_) { "Could not parse to Float." })
  |> promptly.with_validator(fn(x) {
    case x != 0.0 {
      True -> Ok(x)
      False -> Error("Wasn't a non-zero float.")
    }
  })
  |> promptly.prompt(default_formatter("Give me any non-zero float: "))
  |> should.equal(3.14)
}
