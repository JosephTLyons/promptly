import gleam/int
import gleam/regexp
import gleam/string
import gleeunit
import gleeunit/should
import promptly
import promptly/internal/user_input.{type InputStatus}
import promptly/utils

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn text_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal("Give me some text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.prompt
  |> should.equal("Dog")
}

pub fn text_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal("Give me long text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_validator(fn(text) { string.length(text) > 10 })
  |> promptly.prompt
  |> should.equal("I'm a Mongoose!")
}

pub fn text_with_map_validation_test() {
  let result_returning_function =
    result_returning_function(results: [
      "It's in April", "My birthday is 04/12/1990",
    ])

  let validator = fn(text) {
    let assert Ok(re) = regexp.from_string("\\d{2}/\\d{2}/\\d{4}")
    case regexp.scan(re, text) {
      [] -> Error(Nil)
      [match, ..] -> Ok(match.content)
    }
  }
  promptly.new_internal("When is your birthday (dd/mm/yyyy): ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_map_validator(validator)
  |> promptly.prompt
  |> should.equal("04/12/1990")
}

pub fn int_test() {
  let result_returning_function =
    result_returning_function(results: ["Hey", "There", "100", "2"])

  promptly.new_internal("Give me any int", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.prompt
  |> should.equal(100)
}

pub fn int_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["0", "2", "3", "4"])

  promptly.new_internal("Give me an odd int", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_validator(int.is_odd)
  |> promptly.prompt
  |> should.equal(3)
}

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

pub fn int_with_map_to_different_type_validator_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "2", "0.0", "3.14"])

  promptly.new_internal("Give me any non-zero float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_map_validator(fn(value) {
    case value {
      1 -> Ok("a")
      _ -> Ok("b")
    }
  })
  |> promptly.prompt
  |> should.equal("b")
}

pub fn text_with_default_and_no_input_test() {
  let result_returning_function = result_returning_function(results: [""])
  let default = "Hello, World"

  promptly.new_internal(
    "Give me any text (default: \"" <> default <> "\"): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_default(default)
  |> promptly.prompt
  |> should.equal(default)
}

pub fn text_with_default_and_input_test() {
  let result_returning_function = result_returning_function(results: ["Hey"])
  let default = "Hello, World"

  promptly.new_internal(
    "Give me any text (default: \"" <> default <> "\"): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_default("Hello, World")
  |> promptly.prompt
  |> should.equal("Hey")
}

pub fn int_with_default_and_no_input_test() {
  let result_returning_function = result_returning_function(results: [""])

  promptly.new_internal("Give me any int (default: 0): ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_default(0)
  |> promptly.prompt
  |> should.equal(0)
}

pub fn int_with_default_and_input_test() {
  let result_returning_function = result_returning_function(results: ["1"])

  promptly.new_internal("Give me any int (default: 0): ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_default(0)
  |> promptly.prompt
  |> should.equal(1)
}

pub fn int_with_default_and_bad_input_and_then_no_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Only use default with no input
  let result_returning_function =
    result_returning_function(results: ["dog", ""])

  promptly.new_internal("Give me any int (default: 0): ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_default(0)
  |> promptly.prompt
  |> should.equal(0)
}

pub fn int_with_default_and_bad_input_and_then_good_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Second input is good, use that
  let result_returning_function =
    result_returning_function(results: ["dog", "1"])

  promptly.new_internal("Give me any int (default: 0): ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_default(0)
  |> promptly.prompt
  |> should.equal(1)
}

pub fn multiple_with_defaults_test() {
  let result_returning_function = result_returning_function(results: [""])

  promptly.new_internal("Give me any text: ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_default("Hey")
  |> promptly.with_default("Man")
  |> promptly.prompt
  |> should.equal("Hey")
}

// Super duper edge case - but should probably fix this at some point
// pub fn multiple_with_defaults_with_not_provided_as_initial_default_test() {
//   let result_returning_function = result_returning_function(results: [""])

//   promptly.new_internal("Give me any text: ", fn(_, attempt) {
//     result_returning_function(attempt)
//   })
//   |> promptly.with_default("")
//   |> promptly.with_default("Man")
//   |> promptly.prompt
//   |> should.equal("Man")
// }

pub fn date_uses_default_test() {
  let result_returning_function = result_returning_function(results: [""])
  let to_date_validator = utils.to_date_validator()
  let default = utils.Date(month: 1, day: 1, year: 1970)

  promptly.new_internal(
    "Give me a date (default: 01/01/1970): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_map_validator(to_date_validator)
  |> promptly.with_default(default)
  |> promptly.prompt
  |> should.equal(default)
}

pub fn date_does_not_use_default_test() {
  let result_returning_function =
    result_returning_function(results: ["04/12/1990"])
  let to_date_validator = utils.to_date_validator()

  promptly.new_internal(
    "Give me a date (default: 01/01/1970): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_map_validator(to_date_validator)
  |> promptly.with_default(utils.Date(month: 1, day: 1, year: 1970))
  |> promptly.prompt
  |> should.equal(utils.Date(month: 4, day: 12, year: 1990))
}

fn result_returning_function(
  results results: List(String),
) -> fn(Int) -> #(Result(String, Nil), InputStatus) {
  fn(attempt) {
    let assert Ok(input) = at(results, index: attempt)
    user_input.input_internal(input, Ok)
  }
}

fn at(items items: List(a), index index: Int) -> Result(a, Nil) {
  do_at(items:, index:)
}

fn do_at(items items: List(a), index index: Int) -> Result(a, Nil) {
  case items, index {
    _, index if index < 0 -> Error(Nil)
    [_, ..rest], index if index > 0 -> do_at(items: rest, index: index - 1)
    [item, ..], _ -> Ok(item)
    [], _ -> Error(Nil)
  }
}
// TODO: Break up into int, float, and text test modules
// TODD: Clean up tests and add a test for each kind of int, float, and text
