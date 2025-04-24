# promptly

[![Package Version](https://img.shields.io/hexpm/v/promptly)](https://hex.pm/packages/promptly)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/promptly/)

Validated user input.

```sh
gleam add promptly
```

Configure your prompter to be as simple as you like:

```gleam
import gleam/io
import promptly

pub fn main() {
  let name = promptly.new() |> promptly.prompt(fn(_) { "Name: " })
  io.println("Hello, " <> name)
}
```

```txt
Name: Bob
Hello, Bob
```

... or build a complex pipeline with bells and whistles:

```gleam
import gleam/io
import gleam/option.{None, Some}
import promptly

type EntityError {
  NotProvided
  Bad(String)
}

pub fn main() {
  let entity =
    promptly.new()
    |> promptly.with_validator(fn(entity) {
      case entity {
        "" -> Error(NotProvided)
        "joe" | "world" -> Ok(entity)
        _ -> Error(Bad(entity))
      }
    })
    |> promptly.prompt(fn(error) {
      let prompt = "Who are you: "
      case error {
        None -> prompt
        Some(error) -> {
          let error_string = case error {
            NotProvided -> "You must tell me something!"
            Bad(entity) ->
              promptly.quote_text(entity)
              <> " is NOT my favorite thing to greet!"
          }
          "Error: " <> error_string <> "\n" <> prompt
        }
      }
    })

  io.println("Hello, " <> entity <> "!")
}
```

```txt
Who are you:
Error: You must tell me something!
Who are you: Bob
Error: "Bob" is NOT my favorite thing to greet!
Who are you: joe
Hello, joe!
```
