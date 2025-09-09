import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import promptly.{type Error, InputError, ValidationFailed}

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

pub fn default_formatter(prompt: String) -> fn(Option(Error(String))) -> String {
  fn(error) {
    case error {
      Some(error) -> {
        let error = case error {
          InputError -> "Input failed!"
          ValidationFailed(error) -> error
        }
        "Error: " <> error <> "\n" <> prompt
      }
      None -> prompt
    }
  }
}

pub fn default_date_formatter(
  prompt: String,
) -> fn(Option(Error(DateError))) -> String {
  fn(error) {
    case error {
      Some(error) -> {
        let error = case error {
          InputError -> "Input failed!"
          ValidationFailed(_) -> "Failed to parse!"
        }
        "Error: " <> error <> "\n" <> prompt
      }
      None -> prompt
    }
  }
}
