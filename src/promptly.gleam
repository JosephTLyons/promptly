import gleam/float
import gleam/int
import gleam/result
import promptly/internal/user_input.{type InputStatus, NotProvided, Provided}

pub opaque type Prompt(a) {
  Prompt(operation: fn(Int) -> #(Result(a, Nil), InputStatus))
}

pub fn new(text: String) -> Prompt(String) {
  let operation = fn(text, _) { user_input.input(text) }
  new_internal(text, operation)
}

@internal
pub fn new_internal(
  text: String,
  operation: fn(String, Int) -> #(Result(String, Nil), InputStatus),
) -> Prompt(String) {
  let operation = fn(attempt) { operation(text, attempt) }
  Prompt(operation)
}

pub fn as_int(prompt: Prompt(String)) -> Prompt(Int) {
  to_number(prompt, int.parse)
}

pub fn as_float(prompt: Prompt(String)) -> Prompt(Float) {
  to_number(prompt, float.parse)
}

fn to_number(
  prompt: Prompt(String),
  parse: fn(String) -> Result(a, Nil),
) -> Prompt(a) {
  let operation = fn(attempt) {
    let #(res, input) = prompt.operation(attempt)
    let res = result.try(res, parse)
    #(res, input)
  }
  Prompt(operation)
}

pub fn with_default(prompt: Prompt(a), default: a) -> Prompt(a) {
  let operation = fn(attempt) {
    let #(res, input) = prompt.operation(attempt)
    let res = case input {
      NotProvided -> Ok(default)
      Provided -> res
    }
    #(res, Provided)
  }
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
    let #(res, input) = prompt.operation(attempt)
    let res = result.try(res, map_validator)
    #(res, input)
  }
  Prompt(operation)
}

pub fn prompt(prompt: Prompt(a)) {
  prompt_loop(prompt, 0)
}

fn prompt_loop(prompt: Prompt(a), attempt: Int) -> a {
  let #(result, _) = prompt.operation(attempt)

  case result {
    Ok(value) -> value
    Error(_) -> prompt_loop(prompt, attempt + 1)
  }
}
