import gleam/float
import gleam/int
import gleam/result
import input

pub opaque type PromptResult(a, b) {
  PromptResult(operation: fn() -> Result(a, Nil))
}

pub fn int(prompt: String) -> PromptResult(Int, Nil) {
  let operation = fn() { prompt |> input.input |> result.try(int.parse) }
  PromptResult(operation)
}

pub fn float(prompt: String) -> PromptResult(Float, Nil) {
  let operation = fn() { prompt |> input.input |> result.try(float.parse) }
  PromptResult(operation)
}

pub fn string(prompt: String) -> PromptResult(String, Nil) {
  let operation = fn() { prompt |> input.input }
  PromptResult(operation)
}

pub fn with_choice(
  prompt: PromptResult(a, b),
  is_valid_option: fn(a) -> Bool,
) -> PromptResult(a, b) {
  let operation = fn() {
    let input = prompt.operation()
    case input {
      Ok(input) -> {
        case is_valid_option(input) {
          True -> Ok(input)
          False -> Error(Nil)
        }
      }
      Error(_) -> Error(Nil)
    }
  }
  PromptResult(operation)
}

pub fn run(prompt: PromptResult(a, b)) -> a {
  case prompt.operation() {
    Ok(value) -> value
    Error(_) -> run(prompt)
  }
}
