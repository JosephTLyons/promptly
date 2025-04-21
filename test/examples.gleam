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
      options |> list.map(string.lowercase) |> list.contains(lower)
    }
    echo prompt
      |> promptly.new
      |> promptly.with_validator(validator)
      |> promptly.prompt
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

    promptly.new(prompt)
    |> promptly.as_int
    |> promptly.with_validator(fn(a) { a >= lower && a < upper })
    |> promptly.prompt
  }
}

pub fn float_example() {
  fn() {
    promptly.new("Give me a non-zero float: ")
    |> promptly.as_float
    |> promptly.with_validator(fn(a) { a != 0.0 })
    |> promptly.prompt
  }
}

pub fn map_validator_example() {
  fn() {
    let to_date_validator = utils.to_date_validator()
    echo promptly.new("Give me a date (default: 01/01/1970): ")
      |> promptly.with_map_validator(to_date_validator)
      |> promptly.with_default(utils.Date(month: 1, day: 1, year: 1970))
      |> promptly.prompt
  }
}
