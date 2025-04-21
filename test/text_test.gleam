import gleam/regexp
import gleam/string
import gleeunit/should
import promptly
import promptly/utils.{result_returning_function}

pub fn text_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal("Give me some text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.prompt
  |> should.equal("Dog")
}

pub fn text_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal("Give me long text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_validator(fn(text) { string.length(text) > 10 })
  |> promptly.prompt
  |> should.equal("I'm a Mongoose!")
}

pub fn text_with_map_validation_test() {
  let result_returning_function =
    result_returning_function(results: [
      "It's in April", "My birthday is 04/12/1990",
    ])

  let validator = fn(text) {
    let assert Ok(re) = regexp.from_string("\\d{2}/\\d{2}/\\d{4}")
    case regexp.scan(re, text) {
      [] -> Error(Nil)
      [match, ..] -> Ok(match.content)
    }
  }
  promptly.new_internal("When is your birthday (dd/mm/yyyy): ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_map_validator(validator)
  |> promptly.prompt
  |> should.equal("04/12/1990")
}

pub fn text_with_default_and_no_input_test() {
  let result_returning_function = result_returning_function(results: [""])
  let default = "Hello, World"

  promptly.new_internal(
    "Give me any text (default: \"" <> default <> "\"): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_default(default)
  |> promptly.prompt
  |> should.equal(default)
}

pub fn text_with_default_and_input_test() {
  let result_returning_function = result_returning_function(results: ["Hey"])
  let default = "Hello, World"

  promptly.new_internal(
    "Give me any text (default: \"" <> default <> "\"): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_default("Hello, World")
  |> promptly.prompt
  |> should.equal("Hey")
}
