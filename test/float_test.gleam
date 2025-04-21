import gleeunit/should
import promptly
import promptly/utils.{result_returning_function}

pub fn float_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.new_internal("Give me any float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_float
  |> promptly.prompt
  |> should.equal(0.0)
}

pub fn float_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.new_internal("Give me any non-zero float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_float
  |> promptly.with_validator(fn(value) { value != 0.0 })
  |> promptly.prompt
  |> should.equal(3.14)
}
