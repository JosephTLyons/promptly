import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import promptly/internal/user_input.{type InputStatus}

pub fn result_returning_function(
  results results: List(String),
) -> fn(Int) -> #(Result(String, String), InputStatus) {
  fn(attempt) {
    let assert Ok(input) = at(results, index: attempt)
    user_input.input_internal(input, Ok)
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

pub fn to_date_validator() -> fn(String) -> Result(Date, String) {
  fn(text) {
    let error = "Could not convert \"" <> text <> "\" to Date."
    let assert Ok(re) = regexp.from_string("(\\d{2})/(\\d{2})/(\\d{4})")
    case regexp.scan(re, text) {
      [match] -> {
        case match.submatches |> option.all {
          Some(submatches) -> {
            let date_components =
              submatches |> list.map(int.parse) |> result.all
            case date_components {
              Ok([month, day, year]) -> Ok(Date(month:, day:, year:))
              _ -> Error(error)
            }
          }
          None -> Error(error)
        }
      }
      _ -> Error(error)
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
