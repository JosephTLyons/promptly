import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import promptly.{type Error, InputError, ValidationFailed, quote_text}
import promptly/utils

// The examples in this module ensure we don't break parts of the public API
// that are intentionally **NOT** tested, such as `new()`, as it would block
// on user input during testing.
pub fn text_example() {
  let options = ["Danny", "Kayla", "Gina", "Emery"]
  let option_text = string.join(options, ", ")
  let prompt = "Who is my best friend? [" <> option_text <> "]: "

  let validator = fn(text) {
    let lower = string.lowercase(text)
    let is_valid_option =
      options |> list.map(string.lowercase) |> list.contains(lower)
    case is_valid_option {
      True -> Ok(text)
      False -> Error(quote_text(text) <> " isn't a valid option!")
    }
  }

  promptly.new()
  |> promptly.with_validator(validator)
  |> promptly.prompt(utils.default_formatter(prompt))
}

pub fn int_example() {
  let lower = 0
  let upper = 100
  let prompt =
    "Pick a number ["
    <> int.to_string(lower)
    <> ", "
    <> int.to_string(upper)
    <> "): "

  promptly.new()
  |> promptly.as_int(fn(_) { "Could not parse to Int!" })
  |> promptly.with_validator(fn(x) {
    case x >= lower && x < upper {
      True -> Ok(x)
      False -> Error("Isn't in range!")
    }
  })
  |> promptly.prompt(utils.default_formatter(prompt))
}

pub fn float_example() {
  promptly.new()
  |> promptly.as_float(fn(_) { "Could not parse to Float!" })
  |> promptly.with_validator(fn(x) {
    case x != 0.0 {
      True -> Ok(x)
      False -> Error("Wasn't a non-zero float!")
    }
  })
  |> promptly.prompt(utils.default_formatter("Give me a non-zero float: "))
}

pub fn validator_example() {
  let default = "01/01/1970"
  let prompt = "Give me a date (default: " <> default <> "): "
  let to_date_validator = utils.to_date_validator()
  promptly.new()
  |> promptly.with_default(default)
  |> promptly.with_validator(to_date_validator)
  |> promptly.prompt(utils.default_date_formatter(prompt))
}

pub fn custom_prompt_loop_example() {
  let prompter =
    promptly.new()
    |> promptly.as_int(fn(error) { quote_text(error) <> " is not an int!" })
    |> promptly.with_validator(fn(value) {
      case int.is_odd(value) {
        True -> Ok(value)
        False -> Error(int.to_string(value) <> " is even!")
      }
    })

  prompter_loop(prompter, None)
}

fn prompter_loop(
  prompter: promptly.Prompt(a, Error(String)),
  previous_error: Option(Error(String)),
) -> a {
  let prompt = "Give me an int: "
  let input = case previous_error {
    Some(error) -> {
      let error = case error {
        InputError -> "Input failed!"
        ValidationFailed(error) -> error
      }
      "Error: " <> error <> "\n" <> prompt
    }
    None -> prompt
  }
  let response = promptly.prompt_once(prompter, input)

  case response {
    Ok(value) -> value
    Error(error) -> prompter_loop(prompter, Some(error))
  }
}

pub fn readme_simple_example() {
  let name = promptly.new() |> promptly.prompt(fn(_) { "Name: " })
  io.println("Hello, " <> name)
}

type EntityError {
  NotProvided
  Bad(String)
}

pub fn readme_complex_example() {
  let entity =
    promptly.new()
    |> promptly.with_validator(fn(entity) {
      case entity {
        "" -> Error(NotProvided)
        "joe" | "world" -> Ok(entity)
        _ -> Error(Bad(entity))
      }
    })
    |> promptly.prompt(fn(error) {
      let prompt = "Who are you: "
      case error {
        None -> prompt
        Some(error) -> {
          let error_string = case error {
            InputError -> "Input failed!"
            ValidationFailed(error) ->
              case error {
                NotProvided -> "You must tell me something!"
                Bad(entity) ->
                  promptly.quote_text(entity)
                  <> " is NOT my favorite thing to greet!"
              }
          }
          "Error: " <> error_string <> "\n" <> prompt
        }
      }
    })

  io.println("Hello, " <> entity <> "!")
}
