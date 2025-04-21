import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result

pub type Date {
  Date(month: Int, day: Int, year: Int)
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
              _ -> Error(Nil)
            }
          }
          None -> Error(Nil)
        }
      }
      _ -> Error(Nil)
    }
  }
}
