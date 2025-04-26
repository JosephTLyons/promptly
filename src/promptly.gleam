import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import input

/// The error types returned by `promptly`.
pub type Error(a) {
  /// If the underlying [input mechanism](https://github.com/bcpeinhardt/input)
  /// fails, `InputError` will be returned.
  InputError

  /// If any of your custom validation checks fail, `ValidationFailed` will be
  /// returned with your custom error.
  ValidationFailed(a)
}

pub opaque type Prompt(a, b) {
  Prompt(operation: fn(String, Int) -> Result(a, b))
}

/// Used to begin building a new prompt pipeline.
pub fn new() -> Prompt(String, Error(b)) {
  let operation = fn(text, _) { input.input(text) }
  new_internal(operation)
}

@internal
pub fn new_internal(
  operation: fn(String, Int) -> Result(String, Nil),
) -> Prompt(String, Error(b)) {
  let operation = fn(text, attempt) {
    operation(text, attempt) |> result.replace_error(InputError)
  }
  Prompt(operation)
}

/// A convenience function for attempting to convert text input into an integer.
/// Use `with_validator()` for precise control over input manipulation and to
/// verify data. Accepts a function whose input receives the value the user
/// provided, for crafting your own errors.
pub fn as_int(
  prompt: Prompt(String, Error(b)),
  to_error: fn(String) -> b,
) -> Prompt(Int, Error(b)) {
  as_value(prompt, int.parse, to_error)
}

/// Same as `as_int()`, but for float values.
pub fn as_float(
  prompt: Prompt(String, Error(b)),
  to_error: fn(String) -> b,
) -> Prompt(Float, Error(b)) {
  as_value(prompt, float.parse, to_error)
}

fn as_value(
  prompt: Prompt(String, Error(b)),
  as_value: fn(String) -> Result(a, Nil),
  to_error: fn(String) -> b,
) -> Prompt(a, Error(b)) {
  with_validator(prompt, fn(text) {
    text
    |> as_value
    |> result.replace_error(to_error(text))
  })
}

/// A convenience function that allows for providing a default value when the
/// input is an empty string: `""`. Use `with_validator()` for more control over
/// input manipulation and to verify data.
pub fn with_default(
  prompt: Prompt(String, Error(b)),
  default: String,
) -> Prompt(String, Error(b)) {
  with_validator(prompt, fn(text) {
    case text, default {
      "", "" -> Ok(text)
      "", default -> Ok(default)
      text, _ -> Ok(text)
    }
  })
}

/// Allows you to control which data is valid or not, as well as map input data
/// to any value. The validator function should return a result with valid data
/// in `Ok` variants and errors in `Error` variants.
pub fn with_validator(
  prompt: Prompt(a, Error(b)),
  validator: fn(a) -> Result(c, b),
) -> Prompt(c, Error(b)) {
  let operation = fn(text, attempt) {
    text
    |> prompt.operation(attempt)
    |> result.try(fn(value) {
      value
      |> validator
      |> result.map_error(ValidationFailed)
    })
  }
  Prompt(operation)
}

/// Starts a prompt loop. Accepts a custom formatter function to define how your
/// prompt and errors should be printed. The formatter's input is an
/// `Option(String)`, and is `Some` when an error was encountered. Raises errors
/// defined in your pipeline and continuously prompts the user until correct
/// data is provided.
pub fn prompt(prompt: Prompt(a, b), formatter: fn(Option(b)) -> String) -> a {
  prompt_loop(prompt:, formatter:, previous_error: None, attempt: 0)
}

fn prompt_loop(
  prompt prompt: Prompt(a, b),
  previous_error previous_error: Option(b),
  formatter formatter: fn(Option(b)) -> String,
  attempt attempt: Int,
) -> a {
  case previous_error |> formatter |> prompt.operation(attempt) {
    Ok(value) -> value
    Error(error) -> {
      prompt_loop(
        prompt:,
        previous_error: Some(error),
        formatter:,
        attempt: attempt + 1,
      )
    }
  }
}

/// `prompt_once()` will only prompt the user once and will return a result
/// rather than a direct value. You can use this function when you only want to
/// give the user one chance to respond or to manage your own side effects via
/// custom prompt loop logic.
pub fn prompt_once(prompt: Prompt(a, b), text: String) -> Result(a, b) {
  prompt_once_internal(prompt:, text:, attempt: 0)
}

@internal
pub fn prompt_once_internal(
  prompt prompt: Prompt(a, b),
  text text: String,
  attempt attempt: Int,
) -> Result(a, b) {
  prompt.operation(text, attempt)
}

/// A convenience function for returning `text` as `"text"`.
pub fn quote_text(text: String) {
  "\"" <> text <> "\""
}
