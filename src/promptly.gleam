import gleam/float
import gleam/int
import gleam/result
import input

pub opaque type Prompt(a) {
  Prompt(operation: fn(Int) -> Result(a, Nil))
}

pub fn new(text: String) -> Prompt(String) {
  let operation = fn(text, _) { input.input(text) }
  new_internal(text, operation)
}

@internal
pub fn new_internal(
  text: String,
  operation: fn(String, Int) -> Result(String, Nil),
) -> Prompt(String) {
  let operation = operation(text, _)
  Prompt(operation)
}

pub fn int(prompt: Prompt(String)) -> Prompt(Int) {
  to_number(prompt, int.parse)
}

pub fn float(prompt: Prompt(String)) -> Prompt(Float) {
  to_number(prompt, float.parse)
}

fn to_number(
  prompt: Prompt(String),
  parse: fn(String) -> Result(a, Nil),
) -> Prompt(a) {
  let operation = fn(attempt) { prompt.operation(attempt) |> result.try(parse) }
  Prompt(operation)
}

pub fn with_validator(prompt: Prompt(a), validator: fn(a) -> Bool) -> Prompt(a) {
  let map_validator = fn(value) {
    case validator(value) {
      True -> Ok(value)
      False -> Error(Nil)
    }
  }
  with_map_validator(prompt, map_validator)
}

pub fn with_map_validator(
  prompt: Prompt(a),
  map_validator: fn(a) -> Result(b, Nil),
) -> Prompt(b) {
  let operation = fn(attempt) {
    prompt.operation(attempt) |> result.try(map_validator)
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
