import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import promptly/internal/user_input.{type InputStatus, NotProvided, Provided}

pub opaque type Prompt(a) {
  Prompt(operation: fn(String, Int) -> #(Result(a, String), InputStatus))
}

pub fn new() -> Prompt(String) {
  let operation = fn(text, _) { user_input.input(text) }
  new_internal(operation)
}

@internal
pub fn new_internal(
  operation: fn(String, Int) -> #(Result(String, String), InputStatus),
) -> Prompt(String) {
  let operation = fn(text, attempt) { operation(text, attempt) }
  Prompt(operation)
}

pub fn as_int(
  prompt: Prompt(String),
  error: fn(String) -> String,
) -> Prompt(Int) {
  with_validator(prompt, fn(text) {
    text |> int.parse |> result.replace_error(error(text))
  })
}

pub fn as_float(
  prompt: Prompt(String),
  error: fn(String) -> String,
) -> Prompt(Float) {
  with_validator(prompt, fn(text) {
    text |> float.parse |> result.replace_error(error(text))
  })
}

pub fn with_default(prompt: Prompt(a), default: a) -> Prompt(a) {
  let operation = fn(text, attempt) {
    let #(res, input) = prompt.operation(text, attempt)
    let res = case input {
      NotProvided -> Ok(default)
      Provided -> res
    }
    #(res, Provided)
  }
  Prompt(operation)
}

pub fn with_validator(
  prompt: Prompt(a),
  validator: fn(a) -> Result(b, String),
) -> Prompt(b) {
  let operation = fn(text, attempt) {
    let #(res, input) = prompt.operation(text, attempt)
    let res = result.try(res, validator)
    #(res, input)
  }
  Prompt(operation)
}

pub fn prompt(prompt: Prompt(a), formatter: fn(Option(String)) -> String) -> a {
  prompt_loop(prompt, formatter, None, 0)
}

fn prompt_loop(
  prompt: Prompt(a),
  formatter: fn(Option(String)) -> String,
  previous_error: Option(String),
  attempt: Int,
) -> a {
  case try_prompt_internal(prompt, formatter, previous_error, attempt) {
    Ok(value) -> value
    Error(error) -> {
      prompt_loop(prompt, formatter, Some(error), attempt + 1)
    }
  }
}

pub fn try_prompt(
  prompt: Prompt(a),
  formatter: fn(Option(String)) -> String,
) -> Result(a, String) {
  try_prompt_internal(prompt, formatter, None, 0)
}

fn try_prompt_internal(
  prompt: Prompt(a),
  formatter: fn(Option(String)) -> String,
  previous_error: Option(String),
  attempt: Int,
) -> Result(a, String) {
  let prompt_string = formatter(previous_error)
  let #(result, _) = prompt.operation(prompt_string, attempt)
  result
}

pub fn default_formatter(prompt: String) -> fn(Option(String)) -> String {
  fn(error) {
    case error {
      Some(error) -> "Error: " <> error <> "\n" <> prompt
      None -> prompt
    }
  }
}
