import gleam/int
import gleeunit/should
import promptly
import promptly/utils.{result_returning_function}

pub fn int_test() {
  let result_returning_function =
    result_returning_function(results: ["Hey", "There", "100", "2"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.prompt(promptly.default_formatter("Give me any int: "))
  |> should.equal(100)
}

pub fn int_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["0", "2", "3", "4"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_validator(fn(value) {
    case int.is_odd(value) {
      True -> Ok(value)
      False -> Error("Was even.")
    }
  })
  |> promptly.prompt(promptly.default_formatter("Give me an odd int: "))
  |> should.equal(3)
}

pub fn int_with_map_to_different_type_validator_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "2", "0.0", "3.14"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_validator(fn(value) {
    case value {
      1 -> Ok("a")
      _ -> Ok("b")
    }
  })
  |> promptly.prompt(promptly.default_formatter("Give me any non-zero float: "))
  |> should.equal("b")
}

pub fn int_with_default_and_no_input_test() {
  let result_returning_function = result_returning_function(results: [""])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_default(0)
  |> promptly.prompt(promptly.default_formatter(
    "Give me any int (default: 0): ",
  ))
  |> should.equal(0)
}

pub fn int_with_default_and_input_test() {
  let result_returning_function = result_returning_function(results: ["1"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_default(0)
  |> promptly.prompt(promptly.default_formatter(
    "Give me any int (default: 0): ",
  ))
  |> should.equal(1)
}

pub fn int_with_default_and_bad_input_and_then_no_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Only use default with no input
  let result_returning_function =
    result_returning_function(results: ["dog", ""])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_default(0)
  |> promptly.prompt(promptly.default_formatter(
    "Give me any int (default: 0): ",
  ))
  |> should.equal(0)
}

pub fn int_with_default_and_bad_input_and_then_good_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Second input is good, use that
  let result_returning_function =
    result_returning_function(results: ["dog", "1"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_default(0)
  |> promptly.prompt(promptly.default_formatter(
    "Give me any int (default: 0): ",
  ))
  |> should.equal(1)
}

pub fn int_try_prompt_fail_test() {
  let input = 11
  let input_string = int.to_string(input)
  let result_returning_function =
    result_returning_function(results: [input_string])
  let error_message = "\"" <> input_string <> "\" was greater than 10!"

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_default(0)
  |> promptly.with_validator(fn(a) {
    case a <= 10 {
      True -> Ok(a)
      False -> Error(error_message)
    }
  })
  |> promptly.try_prompt(promptly.default_formatter(
    "Give me any int (default: 0): ",
  ))
  |> should.equal(Error(error_message))
}

pub fn int_try_prompt_succeed_test() {
  let input = 1
  let input_string = int.to_string(input)
  let result_returning_function =
    result_returning_function(results: [input_string])
  let error_message = "\"" <> input_string <> "\" was greater than 10!"

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_default(0)
  |> promptly.with_validator(fn(a) {
    case a <= 10 {
      True -> Ok(a)
      False -> Error(error_message)
    }
  })
  |> promptly.try_prompt(promptly.default_formatter(
    "Give me any int (default: 0): ",
  ))
  |> should.equal(Ok(input))
}
