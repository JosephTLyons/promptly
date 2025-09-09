import gleam/int
import gleam/option.{None, Some}
import gleeunit/should
import promptly.{InputError, ValidationFailed, quote_text}
import promptly/utils

pub fn with_default_as_empty_string_test() {
  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> ""
      1 -> "1"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.with_default("")
  |> promptly.as_int(fn(_) { "" })
  |> promptly.prompt(utils.default_formatter("Give me any text: "))
  |> should.equal(1)
}

// This doesn't make sense, but someone will try to do this
pub fn multiple_with_defaults_test() {
  // With multiple with_defaults, we should always pick the first non-empty
  // string one
  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> ""
      1 -> "1"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.with_default("")
  |> promptly.with_default("0")
  |> promptly.with_default("")
  |> promptly.with_default("1")
  |> promptly.with_default("")
  |> promptly.as_int(fn(_) { "" })
  |> promptly.prompt(utils.default_formatter("Give me any text: "))
  |> should.equal(0)
}

pub fn date_uses_default_test() {
  let to_date_validator = utils.to_date_validator()
  let default = "01/01/1970"
  let prompt = "Give me a date (default: " <> default <> "): "

  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> ""
      _ -> panic
    }
    |> Ok
  })
  |> promptly.with_default(default)
  |> promptly.with_validator(to_date_validator)
  |> promptly.prompt(utils.default_date_formatter(prompt))
  |> should.equal(utils.Date(month: 1, day: 1, year: 1970))
}

pub fn date_does_not_use_default_test() {
  let to_date_validator = utils.to_date_validator()
  let default = "01/01/1970"
  let prompt = "Give me a date (default: " <> default <> "): "

  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "04/12/1990"
      _ -> panic
    }
    |> Ok
  })
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
  let prompt = "How old are you: "

  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "16"
      1 -> "18"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.as_int(fn(text) { ParseError(text) })
  |> promptly.with_validator(fn(input) {
    case input >= 18 {
      True -> Ok(AgeSuccess(input))
      False -> Error(AgeError(input))
    }
  })
  |> promptly.prompt(fn(error) {
    case error {
      Some(error) -> {
        let error = case error {
          InputError -> "Input failed!"
          ValidationFailed(error) ->
            case error {
              AgeError(age) -> int.to_string(age) <> " is not old enough!"
              ParseError(text) -> "Could not parse " <> quote_text(text) <> "!"
            }
        }
        "Error: " <> error <> "\n" <> prompt
      }

      None -> prompt
    }
  })
  |> should.equal(AgeSuccess(18))
}
