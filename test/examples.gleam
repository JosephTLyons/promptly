import gleam/int
import gleam/list
import gleam/regexp
import gleam/string
import promptly

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
      |> promptly.run
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
    |> promptly.int
    |> promptly.with_validator(fn(a) { a >= lower && a < upper })
    |> promptly.run
  }
}

pub fn float_example() {
  fn() {
    promptly.new("Give me a non-zero float: ")
    |> promptly.float
    |> promptly.with_validator(fn(a) { a != 0.0 })
    |> promptly.run
  }
}

pub fn map_validator_example() {
  fn() {
    let validator = fn(text) {
      let assert Ok(re) = regexp.from_string("\\d{2}/\\d{2}/\\d{4}")
      case regexp.scan(re, text) {
        [] -> Error(Nil)
        [match, ..] -> Ok(match.content)
      }
    }
    promptly.new("When is your birthday (dd/mm/yyyy): ")
    |> promptly.with_map_validator(validator)
    |> promptly.run
  }
}
