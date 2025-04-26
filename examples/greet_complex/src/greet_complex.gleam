import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/string
import promptly.{type Error, InputError, ValidationFailed}

type EntityError {
  NotProvided
  Bad(String)
}

pub fn main() -> Nil {
  let entity =
    promptly.new()
    |> promptly.with_validator(validator)
    |> promptly.prompt(formatter)

  io.println("Hello, " <> entity <> "!")
}

fn validator(entity: String) -> Result(String, EntityError) {
  case string.lowercase(entity) {
    "" -> Error(NotProvided)
    "joe" | "world" -> Ok(entity)
    _ -> Error(Bad(entity))
  }
}

fn formatter(error: Option(Error(EntityError))) -> String {
  let prompt = "Who are you: "
  case error {
    None -> prompt
    Some(error) -> {
      let error = case error {
        InputError -> "Input failed!"
        ValidationFailed(error) ->
          case error {
            NotProvided -> "C'mon!"
            Bad(entity) ->
              promptly.quote_text(entity)
              <> "? That sounds lovely, but try again!"
          }
      }
      error <> "\n" <> prompt
    }
  }
}
