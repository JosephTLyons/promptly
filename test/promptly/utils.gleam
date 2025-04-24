import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result

pub fn input_internal(
  text: String,
  input_function: fn(String) -> Result(String, Nil),
) -> String {
  let assert Ok(text) = input_function(text)
  text
}

pub fn response_generator(
  responses responses: List(String),
) -> fn(Int) -> String {
  fn(attempt) {
    let assert Ok(input) = at(responses, index: attempt)
    input_internal(input, Ok)
  }
}

pub fn at(items items: List(a), index index: Int) -> Result(a, Nil) {
  do_at(items:, index:)
}

pub fn do_at(items items: List(a), index index: Int) -> Result(a, Nil) {
  case items, index {
    _, index if index < 0 -> Error(Nil)
    [_, ..rest], index if index > 0 -> do_at(items: rest, index: index - 1)
    [item, ..], _ -> Ok(item)
    [], _ -> Error(Nil)
  }
}

pub type Date {
  Date(month: Int, day: Int, year: Int)
}

pub type DateError {
  ParseError1
}

pub fn to_date_validator() {
  fn(text) {
    let assert Ok(re) = regexp.from_string("(\\d{2})/(\\d{2})/(\\d{4})")
    case regexp.scan(re, text) {
      [match] -> {
        case match.submatches |> option.all {
          Some(submatches) -> {
            let date_components =
              submatches |> list.map(int.parse) |> result.all
            case date_components {
              Ok([month, day, year]) -> Ok(Date(month:, day:, year:))
              _ -> Error(ParseError1)
            }
          }
          None -> Error(ParseError1)
        }
      }
      _ -> Error(ParseError1)
    }
  }
}

pub fn default_formatter(prompt: String) -> fn(Option(String)) -> String {
  fn(error) {
    case error {
      Some(error) -> "Error: " <> error <> "\n" <> prompt
      None -> prompt
    }
  }
}

pub fn default_date_formatter(prompt: String) -> fn(Option(DateError)) -> String {
  fn(error) {
    case error {
      Some(error) ->
        case error {
          ParseError1 -> "Error: Failed to parse"
        }
      None -> prompt
    }
  }
}
