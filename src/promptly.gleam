import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import input

pub opaque type Prompt(a, b) {
  Prompt(operation: fn(String, Int) -> Result(a, b))
}

/// Used to begin building a new prompt pipeline.
pub fn new() -> Prompt(String, b) {
  let operation = fn(text, _) {
    // Find a way to handle this without breaking the generic types
    let assert Ok(text) = input.input(text)
    text
  }
  new_internal(operation)
}

@internal
pub fn new_internal(operation: fn(String, Int) -> String) -> Prompt(String, b) {
  let operation = fn(text, attempt) { operation(text, attempt) |> Ok }
  Prompt(operation)
}

/// A convenience function for attempting to convert text input into an integer.
/// Use `with_validator()` for more control over input manipulation and to verify data.
/// Accepts a function whose input receives the value the user provided, for designing your own error messages.
pub fn as_int(
  prompt: Prompt(String, b),
  error: fn(String) -> b,
) -> Prompt(Int, b) {
  with_validator(prompt, fn(text) {
    text
    |> int.parse
    |> result.replace_error(error(text))
  })
}

/// Same as `as_int()`, but for float values.
pub fn as_float(
  prompt: Prompt(String, b),
  error: fn(String) -> b,
) -> Prompt(Float, b) {
  with_validator(prompt, fn(text) {
    text
    |> float.parse
    |> result.replace_error(error(text))
  })
}

/// Allows you to provide a default value when the user inputs an empty string: `""`.
pub fn with_default(
  prompt: Prompt(String, b),
  default: String,
) -> Prompt(String, b) {
  with_validator(prompt, fn(text) {
    case text, default {
      "", "" -> Ok(text)
      "", default -> Ok(default)
      text, _ -> Ok(text)
    }
  })
}

/// Allows you to control which data is valid or not, as well as map input data to any value.
/// The validator function should return a result with valid data in `Ok` variants and errors in `Error` variants.
pub fn with_validator(
  prompt: Prompt(a, b),
  validator: fn(a) -> Result(c, b),
) -> Prompt(c, b) {
  let operation = fn(text, attempt) {
    text |> prompt.operation(attempt) |> result.try(validator)
  }
  Prompt(operation)
}

/// Starts a prompt loop. Accepts a formatter function to define how to print the prompt.
/// Supply a custom formatter function to define how your prompt and errors should be printed.
/// The formatter's input is an `Option(String)`, and is `Some` when an error was encountered.
/// Raises errors defined in your pipeline and continuously prompts the user until correct data is provided.
pub fn prompt(prompt: Prompt(a, b), formatter: fn(Option(b)) -> String) -> a {
  prompt_loop(prompt:, formatter:, previous_error: None, attempt: 0)
}

fn prompt_loop(
  prompt prompt: Prompt(a, b),
  formatter formatter: fn(Option(b)) -> String,
  previous_error previous_error: Option(b),
  attempt attempt: Int,
) -> a {
  case try_prompt_internal(prompt:, formatter:, previous_error:, attempt:) {
    Ok(value) -> value
    Error(error) -> {
      prompt_loop(
        prompt:,
        formatter:,
        previous_error: Some(error),
        attempt: attempt + 1,
      )
    }
  }
}

/// Same as `prompt()`, except that it only prompts the user once and returns a result.
/// Useful for defining your own prompt loop logic.
pub fn try_prompt(
  prompt: Prompt(a, b),
  formatter: fn(Option(b)) -> String,
  previous_error: Option(b),
) -> Result(a, b) {
  try_prompt_internal(prompt:, formatter:, previous_error:, attempt: 0)
}

fn try_prompt_internal(
  prompt prompt: Prompt(a, b),
  formatter formatter: fn(Option(b)) -> String,
  previous_error previous_error: Option(b),
  attempt attempt: Int,
) -> Result(a, b) {
  previous_error |> formatter |> prompt.operation(attempt)
}
