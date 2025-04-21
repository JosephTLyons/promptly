import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result
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

pub type Date {
  Date(day: Int, month: Int, year: Int)
}

pub fn map_validator_example() {
  fn() {
    let to_date_validator = fn(text) {
      let assert Ok(re) = regexp.from_string("(\\d{2})/(\\d{2})/(\\d{4})")
      case regexp.scan(re, text) {
        [match] -> {
          case match.submatches |> option.all {
            Some(submatches) -> {
              let date_components =
                submatches |> list.map(int.parse) |> result.all
              case date_components {
                Ok([day, month, year]) -> Ok(Date(day:, month:, year:))
                _ -> Error(Nil)
              }
            }
            None -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }

    echo promptly.new("Give me a date (default: 01/01/1970): ")
      |> promptly.with_map_validator(to_date_validator)
      |> promptly.with_default(Date(day: 1, month: 1, year: 1970))
      |> promptly.prompt
  }
}
