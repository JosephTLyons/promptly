import gleeunit/should
import promptly
import promptly/utils.{default_formatter, result_returning_function}

pub fn with_default_as_empty_string_test() {
  let result_returning_function = result_returning_function(results: ["", "1"])

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.with_default("")
  |> promptly.as_int(fn(_) { "" })
  |> promptly.prompt(default_formatter("Give me any text: "))
  |> should.equal(1)
}

// This doesn't make sense, but someone will try to do this
pub fn multiple_with_defaults_test() {
  let result_returning_function = result_returning_function(results: ["", "1"])

  // With multiple with_defaults, we should always pick the first non-empty
  // string one
  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.with_default("")
  |> promptly.with_default("0")
  |> promptly.with_default("")
  |> promptly.with_default("1")
  |> promptly.with_default("")
  |> promptly.as_int(fn(_) { "" })
  |> promptly.prompt(default_formatter("Give me any text: "))
  |> should.equal(0)
}

pub fn date_uses_default_test() {
  let result_returning_function = result_returning_function(results: [""])
  let to_date_validator = utils.to_date_validator()
  let default = "01/01/1970"

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.with_default(default)
  |> promptly.with_validator(to_date_validator)
  |> promptly.prompt(default_formatter(
    "Give me a date (default: " <> default <> "): ",
  ))
  |> should.equal(utils.Date(month: 1, day: 1, year: 1970))
}

pub fn date_does_not_use_default_test() {
  let result_returning_function =
    result_returning_function(results: ["04/12/1990"])
  let to_date_validator = utils.to_date_validator()
  let default = "01/01/1970"

  promptly.new_internal(fn(_, attempt) { result_returning_function(attempt) })
  |> promptly.with_default(default)
  |> promptly.with_validator(to_date_validator)
  |> promptly.prompt(default_formatter(
    "Give me a date (default: " <> default <> "): ",
  ))
  |> should.equal(utils.Date(month: 4, day: 12, year: 1990))
}
