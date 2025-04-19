import gleam/float
import gleam/int
import gleam/result
import input

pub opaque type Prompt(a) {
  Prompt(operation: fn() -> Result(a, Nil))
}

pub fn int(prompt: String) -> Prompt(Int) {
  let operation = fn() { prompt |> input.input |> result.try(int.parse) }
  Prompt(operation)
}

pub fn float(prompt: String) -> Prompt(Float) {
  let operation = fn() { prompt |> input.input |> result.try(float.parse) }
  Prompt(operation)
}

pub fn string(prompt: String) -> Prompt(String) {
  let operation = fn() { prompt |> input.input }
  Prompt(operation)
}

pub fn with_validator(prompt: Prompt(a), is_valid: fn(a) -> Bool) -> Prompt(a) {
  let operation = fn() {
    let operation = prompt.operation()
    case operation {
      Ok(input) -> {
        case is_valid(input) {
          True -> Ok(input)
          False -> Error(Nil)
        }
      }
      Error(_) -> Error(Nil)
    }
  }
  Prompt(operation)
}

pub fn run(prompt: Prompt(a)) -> a {
  case prompt.operation() {
    Ok(value) -> value
    Error(_) -> run(prompt)
  }
}
