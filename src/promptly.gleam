import gleam/float
import gleam/int
import gleam/result
import input

pub opaque type Prompt(a) {
  Prompt(operation: fn(Int) -> Result(a, Nil))
}

pub fn int(prompt: String) -> Prompt(Int) {
  int_internal(prompt, fn(text, _) { input.input(text) })
}

@internal
pub fn int_internal(
  prompt: String,
  input_function: fn(String, Int) -> Result(String, Nil),
) -> Prompt(Int) {
  let operation = fn(count) {
    prompt |> input_function(count) |> result.try(int.parse)
  }
  Prompt(operation)
}

pub fn float(prompt: String) -> Prompt(Float) {
  prompt |> float_internal(fn(text, _) { input.input(text) })
}

@internal
pub fn float_internal(
  prompt: String,
  input_function: fn(String, Int) -> Result(String, Nil),
) -> Prompt(Float) {
  let operation = fn(count) {
    prompt |> input_function(count) |> result.try(float.parse)
  }
  Prompt(operation)
}

pub fn string(prompt: String) -> Prompt(String) {
  string_internal(prompt, fn(text, _) { input.input(text) })
}

@internal
pub fn string_internal(
  prompt: String,
  input_function: fn(String, Int) -> Result(String, Nil),
) -> Prompt(String) {
  let operation = fn(count) { input_function(prompt, count) }
  Prompt(operation)
}

pub fn with_validator(prompt: Prompt(a), is_valid: fn(a) -> Bool) -> Prompt(a) {
  let operation = fn(count) {
    let operation = prompt.operation(count)
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
