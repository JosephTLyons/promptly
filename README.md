# promptly

[![Package Version](https://img.shields.io/hexpm/v/promptly)](https://hex.pm/packages/promptly)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/promptly/)

Validated user input.

## Installation

```sh
gleam add promptly
```

## Usage

Configure your prompter to be as simple as you like:

```gleam
import gleam/io
import promptly

pub fn main() -> Nil {
  let name = promptly.new() |> promptly.prompt(fn(_) { "Name: " })
  io.println("Hello, " <> name)
}
```

```txt
Name: Joe
Hello, Joe
```

... or build something more complex with input validation:

```gleam
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
```

```txt
Who are you:
C'mon!
Who are you: Bob
"Bob"? That sounds lovely, but try again!
Who are you: Joe
Hello, Joe!
```

## Tips

- Use your own error types, along with `prompt_once`, to build custom prompt loops with specialized logic.
- Add [`gleam-community/ansi`](https://github.com/gleam-community/ansi) for pretty output.
