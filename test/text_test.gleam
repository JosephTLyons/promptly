import gleam/regexp
import gleam/string
import gleeunit/should
import promptly.{quote_text}
import promptly/utils

pub fn text_test() {
  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "Dog"
      1 -> "Bear"
      2 -> "I'm a Mongoose!"
      3 -> "Cat"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.prompt(utils.default_formatter("Give me some text: "))
  |> should.equal("Dog")
}

pub fn text_with_validation_test() {
  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "Dog"
      1 -> "Bear"
      2 -> "I'm a Mongoose!"
      3 -> "Cat"
      _ -> panic
    }
    |> Ok
  })
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
  let validator = fn(text) {
    let assert Ok(re) = regexp.from_string("\\d{2}/\\d{2}/\\d{4}")
    case regexp.scan(re, text) {
      [] -> Error("Date format was incorrect!")
      [match, ..] -> Ok(match.content)
    }
  }
  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "It's in April"
      1 -> "My birthday is 04/12/1990"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.with_validator(validator)
  |> promptly.prompt(utils.default_formatter(
    "When is your birthday (dd/mm/yyyy): ",
  ))
  |> should.equal("04/12/1990")
}

pub fn text_with_default_and_no_input_test() {
  let default = "Hello, World"

  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> ""
      _ -> panic
    }
    |> Ok
  })
  |> promptly.with_default(default)
  |> promptly.prompt(utils.default_formatter(
    "Give me any text (default: " <> quote_text(default) <> "): ",
  ))
  |> should.equal(default)
}

pub fn text_with_default_and_input_test() {
  let default = "Hello, World"

  promptly.new_internal(fn(_, attempt) {
    case attempt {
      0 -> "Hey"
      _ -> panic
    }
    |> Ok
  })
  |> promptly.with_default("Hello, World")
  |> promptly.prompt(utils.default_formatter(
    "Give me any text (default: " <> quote_text(default) <> "): ",
  ))
  |> should.equal("Hey")
}
