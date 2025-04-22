import gleam/int
import gleam/list
import gleam/string
import promptly
import promptly/utils

// The examples in this module ensure we don't break parts of the public API
// that are intentionally **NOT** tested, such as `new()`, as it would block
// on user input during testing.
pub fn text_example() {
  fn() {
    let options = ["Danny", "Kayla", "Gina", "Emery"]
    let option_text = string.join(options, ", ")
    let prompt = "Who is my best friend? [" <> option_text <> "]: "

    let validator = fn(a) {
      let lower = string.lowercase(a)
      let is_valid_option =
        options |> list.map(string.lowercase) |> list.contains(lower)
      case is_valid_option {
        True -> Ok(a)
        False -> Error("\"" <> a <> "\" isn't a valid option.")
      }
    }

    promptly.new()
    |> promptly.with_validator(validator)
    |> promptly.prompt(promptly.default_formatter(prompt))
  }
}

pub fn int_example() {
  fn() {
    let lower = 0
    let upper = 100
    let prompt =
      "Pick a number ["
      <> int.to_string(lower)
      <> ", "
      <> int.to_string(upper)
      <> "): "

    promptly.new()
    |> promptly.as_int(fn(_) { "Could not parse to Int." })
    |> promptly.with_validator(fn(a) {
      case a >= lower && a < upper {
        True -> Ok(a)
        False -> Error("Isn't in range.")
      }
    })
    |> promptly.prompt(promptly.default_formatter(prompt))
  }
}

pub fn float_example() {
  fn() {
    promptly.new()
    |> promptly.as_float(fn(_) { "Could not parse to Float." })
    |> promptly.with_validator(fn(a) {
      case a != 0.0 {
        True -> Ok(a)
        False -> Error("Wasn't a non-zero float.")
      }
    })
    |> promptly.prompt(promptly.default_formatter("Give me a non-zero float: "))
  }
}

pub fn validator_example() {
  fn() {
    let to_date_validator = utils.to_date_validator()
    promptly.new()
    |> promptly.with_validator(to_date_validator)
    |> promptly.with_default(utils.Date(month: 1, day: 1, year: 1970))
    |> promptly.prompt(promptly.default_formatter(
      "Give me a date (default: 01/01/1970): ",
    ))
  }
}
