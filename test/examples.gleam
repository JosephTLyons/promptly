import gleam/int
import gleam/list
import gleam/string
import promptly
import promptly/utils.{default_formatter}

// The examples in this module ensure we don't break parts of the public API
// that are intentionally **NOT** tested, such as `new()`, as it would block
// on user input during testing.
pub fn text_example() {
  let options = ["Danny", "Kayla", "Gina", "Emery"]
  let option_text = string.join(options, ", ")
  let prompt = "Who is my best friend? [" <> option_text <> "]: "

  let validator = fn(text) {
    let lower = string.lowercase(text)
    let is_valid_option =
      options |> list.map(string.lowercase) |> list.contains(lower)
    case is_valid_option {
      True -> Ok(text)
      False -> Error("\"" <> text <> "\" isn't a valid option.")
    }
  }

  promptly.new()
  |> promptly.with_validator(validator)
  |> promptly.prompt(default_formatter(prompt))
}

pub fn int_example() {
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
  |> promptly.with_validator(fn(x) {
    case x >= lower && x < upper {
      True -> Ok(x)
      False -> Error("Isn't in range.")
    }
  })
  |> promptly.prompt(default_formatter(prompt))
}

pub fn float_example() {
  promptly.new()
  |> promptly.as_float(fn(_) { "Could not parse to Float." })
  |> promptly.with_validator(fn(x) {
    case x != 0.0 {
      True -> Ok(x)
      False -> Error("Wasn't a non-zero float.")
    }
  })
  |> promptly.prompt(default_formatter("Give me a non-zero float: "))
}

pub fn validator_example() {
  let default = "01/01/1970"
  let prompt = "Give me a date (default: " <> default <> "): "
  let to_date_validator = utils.to_date_validator()
  promptly.new()
  |> promptly.with_default(default)
  |> promptly.with_validator(to_date_validator)
  |> promptly.prompt(utils.default_date_formatter(prompt))
}
