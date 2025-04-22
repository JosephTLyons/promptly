import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import promptly/internal/user_input.{type InputStatus, NotProvided, Provided}

pub opaque type Prompt(a) {
  Prompt(operation: fn(String, Int) -> #(Result(a, String), InputStatus))
}

/// Used to begin building a new prompt pipeline.
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

/// A convenience function for attempting to convert text input into an integer.
/// Use `with_validator()` for more control over input manipulation and to verify data.
/// Accepts a function whose input receives the value the user provided, for designing your own error messages.
pub fn as_int(
  prompt: Prompt(String),
  error: fn(String) -> String,
) -> Prompt(Int) {
  with_validator(prompt, fn(text) {
    text |> int.parse |> result.replace_error(error(text))
  })
}

/// Same as `as_int()`, but for float values.
pub fn as_float(
  prompt: Prompt(String),
  error: fn(String) -> String,
) -> Prompt(Float) {
  with_validator(prompt, fn(text) {
    text |> float.parse |> result.replace_error(error(text))
  })
}

/// Allows you to provide a default value when the user inputs an empty string: `""`.
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

/// Allows you to control which data is valid or not, as well as map input data to any value.
/// The validator function should return a result with valid data as `Ok` and error strings as `Error`.
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

/// Starts a prompt loop. Accepts a formatter function to define how to print the prompt.
/// Supply a custom formatter function to define how your prompt and errors should be printed.
/// The formatter's input is an `Option(String)`, and is `Some` when an error was encountered.
/// Raises errors defined in your pipeline and continuously prompts the user until correct data is provided.
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

/// Same as `prompt()`, except that it only prompts the user once and returns a result.
/// Useful for defining your own prompt loop logic.
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
