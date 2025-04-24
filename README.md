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

pub fn main() {
  let name = promptly.new() |> promptly.prompt(fn(_) { "Name: " })
  io.println("Hello, " <> name)
}
```

```txt
Name: Bob
Hello, Bob
```

Add some validation:

```gleam
import gleam/int
import gleam/io
import gleam/option.{None, Some}
import promptly

pub fn main() {
  let number =
    promptly.new()
    |> promptly.as_int(fn(_) { "Not an int!" })
    |> promptly.prompt(fn(error) {
      let prompt = "Pick a number: "
      case error {
        Some(error) -> "Error: " <> error <> "\n" <> prompt
        None -> prompt
      }
    })

  io.println("You chose: " <> int.to_string(number) <> "!")
}
```

```txt
Pick a number: dog
Error: Not an int!
Pick a number: 25
You chose: 25!
```

... or build a complex pipeline with custom error types:

```gleam
import gleam/io
import gleam/option.{type Option, None, Some}
import promptly

type EntityError {
  NotProvided
  Bad(String)
}

pub fn main() {
  let entity =
    promptly.new()
    |> promptly.with_validator(validator)
    |> promptly.prompt(formatter)

  io.println("Hello, " <> entity <> "!")
}

fn validator(entity: String) -> Result(String, EntityError) {
  case entity {
    "" -> Error(NotProvided)
    "Joe" | "World" -> Ok(entity)
    _ -> Error(Bad(entity))
  }
}

fn formatter(error: Option(EntityError)) -> String {
  let prompt = "Who are you: "
  case error {
    None -> prompt
    Some(error) -> {
      let error_string = case error {
        NotProvided -> "You must tell me something!"
        Bad(entity) ->
          promptly.quote_text(entity) <> " is NOT my favorite thing to greet!"
      }
      "Error: " <> error_string <> "\n" <> prompt
    }
  }
}
```

```txt
Who are you:
Error: You must tell me something!
Who are you: Bob
Error: "Bob" is NOT my favorite thing to greet!
Who are you: Joe
Hello, Joe!
```

## Tips

- Build your own custom prompt loops with `prompt_once`.
- Add [`gleam-community/ansi`](https://github.com/gleam-community/ansi) for pretty output.
