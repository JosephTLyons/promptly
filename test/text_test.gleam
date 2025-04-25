import gleam/regexp
import gleam/string
import gleeunit/should
import promptly.{quote_text}
import promptly/utils.{response_generator}

pub fn text_test() {
  let response_generator =
    response_generator(responses: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.prompt(utils.default_formatter("Give me some text: "))
  |> should.equal("Dog")
}

pub fn text_with_validation_test() {
  let response_generator =
    response_generator(responses: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_validator(fn(text) {
    case string.length(text) > 10 {
      True -> Ok(text)
      False -> Error("String length was >= 10!")
    }
  })
  |> promptly.prompt(utils.default_formatter("Give me long text: "))
  |> should.equal("I'm a Mongoose!")
}

pub fn text_with_map_validation_test() {
  let response_generator =
    response_generator(responses: ["It's in April", "My birthday is 04/12/1990"])

  let validator = fn(text) {
    let assert Ok(re) = regexp.from_string("\\d{2}/\\d{2}/\\d{4}")
    case regexp.scan(re, text) {
      [] -> Error("Date format was incorrect!")
      [match, ..] -> Ok(match.content)
    }
  }
  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_validator(validator)
  |> promptly.prompt(utils.default_formatter(
    "When is your birthday (dd/mm/yyyy): ",
  ))
  |> should.equal("04/12/1990")
}

pub fn text_with_default_and_no_input_test() {
  let response_generator = response_generator(responses: [""])
  let default = "Hello, World"

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default(default)
  |> promptly.prompt(utils.default_formatter(
    "Give me any text (default: " <> quote_text(default) <> "): ",
  ))
  |> should.equal(default)
}

pub fn text_with_default_and_input_test() {
  let response_generator = response_generator(responses: ["Hey"])
  let default = "Hello, World"

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default("Hello, World")
  |> promptly.prompt(utils.default_formatter(
    "Give me any text (default: " <> quote_text(default) <> "): ",
  ))
  |> should.equal("Hey")
}
