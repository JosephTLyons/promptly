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
  let operation = fn(attempt) {
    prompt.operation(attempt) |> result.try(int.parse)
  }
  Prompt(operation)
}

pub fn float(prompt: Prompt(String)) -> Prompt(Float) {
  let operation = fn(attempt) {
    prompt.operation(attempt) |> result.try(float.parse)
  }
  Prompt(operation)
}

pub fn with_validator(prompt: Prompt(a), validator: fn(a) -> Bool) -> Prompt(a) {
  with_map_validator(prompt, fn(value) {
    case validator(value) {
      True -> Ok(value)
      False -> Error(Nil)
    }
  })
}

pub fn with_map_validator(
  prompt: Prompt(a),
  map_validator: fn(a) -> Result(a, Nil),
) -> Prompt(a) {
  let operation = fn(attempt) {
    let operation = prompt.operation(attempt)
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

pub fn prompt(prompt: Prompt(a)) {
  prompt_internal(prompt, 0)
}

@internal
pub fn prompt_internal(prompt: Prompt(a), attempt: Int) -> a {
  case prompt.operation(attempt) {
    Ok(value) -> value
    Error(_) -> prompt_internal(prompt, attempt + 1)
  }
}
