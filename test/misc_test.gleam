import gleam/int
import gleam/option.{None, Some}
import gleeunit/should
import promptly
import promptly/utils.{default_formatter, response_generator}

pub fn with_default_as_empty_string_test() {
  let response_generator = response_generator(responses: ["", "1"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default("")
  |> promptly.as_int(fn(_) { "" })
  |> promptly.prompt(default_formatter("Give me any text: "))
  |> should.equal(1)
}

// This doesn't make sense, but someone will try to do this
pub fn multiple_with_defaults_test() {
  let response_generator = response_generator(responses: ["", "1"])

  // With multiple with_defaults, we should always pick the first non-empty
  // string one
  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
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
  let response_generator = response_generator(responses: [""])
  let to_date_validator = utils.to_date_validator()
  let default = "01/01/1970"
  let prompt = "Give me a date (default: " <> default <> "): "

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default(default)
  |> promptly.with_validator(to_date_validator)
  |> promptly.prompt(utils.default_date_formatter(prompt))
  |> should.equal(utils.Date(month: 1, day: 1, year: 1970))
}

pub fn date_does_not_use_default_test() {
  let response_generator = response_generator(responses: ["04/12/1990"])
  let to_date_validator = utils.to_date_validator()
  let default = "01/01/1970"
  let prompt = "Give me a date (default: " <> default <> "): "

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default(default)
  |> promptly.with_validator(to_date_validator)
  |> promptly.prompt(utils.default_date_formatter(prompt))
  |> should.equal(utils.Date(month: 4, day: 12, year: 1990))
}

type AgeSuccess {
  AgeSuccess(Int)
}

type AgeError {
  ParseError(String)
  AgeError(Int)
}

pub fn custom_types_test() {
  let response_generator = response_generator(responses: ["16", "18"])
  let prompt = "How old are you: "

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.as_int(fn(text) { ParseError(text) })
  |> promptly.with_validator(fn(input) {
    case input >= 18 {
      True -> Ok(AgeSuccess(input))
      False -> Error(AgeError(input))
    }
  })
  |> promptly.prompt(fn(error) {
    case error {
      Some(error) ->
        case error {
          AgeError(age) ->
            "Error: " <> int.to_string(age) <> " is not old enough.\n" <> prompt
          ParseError(text) ->
            "Error: Could not parse \"" <> text <> "\".\n" <> prompt
        }
      None -> prompt
    }
  })
  |> should.equal(AgeSuccess(18))
}
