import gleam/float
import gleam/int
import gleam/result
import input

pub opaque type Prompt(a) {
  Prompt(operation: fn(Int) -> Result(a, Nil))
}

pub fn new(prompt: String) -> Prompt(String) {
  let operation = fn(text, _) { input.input(text) }
  new_internal(prompt, operation)
}

@internal
pub fn new_internal(
  prompt: String,
  operation: fn(String, Int) -> Result(String, Nil),
) -> Prompt(String) {
  Prompt(operation(prompt, _))
}

pub fn int(prompt: Prompt(String)) -> Prompt(Int) {
  let operation = fn(count) { prompt.operation(count) |> result.try(int.parse) }
  Prompt(operation)
}

pub fn float(prompt: Prompt(String)) -> Prompt(Float) {
  let operation = fn(count) {
    prompt.operation(count) |> result.try(float.parse)
  }
  Prompt(operation)
}

pub fn with_validator(prompt: Prompt(a), validator: fn(a) -> Bool) -> Prompt(a) {
  with_map_validator(prompt, fn(a) {
    case validator(a) {
      False -> Error(Nil)
      True -> Ok(a)
    }
  })
}

pub fn with_map_validator(
  prompt: Prompt(a),
  map_validator: fn(a) -> Result(a, Nil),
) -> Prompt(a) {
  let operation = fn(count) {
    let operation = prompt.operation(count)
    case operation {
      Ok(input) -> {
        case map_validator(input) {
          Ok(input) -> Ok(input)
          Error(_) -> Error(Nil)
        }
      }
      Error(_) -> Error(Nil)
    }
  }
  Prompt(operation)
}

pub fn run(prompt: Prompt(a)) {
  run_internal(prompt, 0)
}

@internal
pub fn run_internal(prompt: Prompt(a), attempt: Int) -> a {
  case prompt.operation(attempt) {
    Ok(value) -> value
    Error(_) -> run_internal(prompt, attempt + 1)
  }
}
