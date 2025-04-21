import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/string
import gleeunit
import gleeunit/should
import promptly

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn promptly_text_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal("Give me some text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.prompt
  |> should.equal("Dog")
}

pub fn promptly_text_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.new_internal("Give me long text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_validator(fn(text) { string.length(text) > 10 })
  |> promptly.prompt
  |> should.equal("I'm a Mongoose!")
}

pub fn promptly_text_with_map_validation_test() {
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

pub fn promptly_int_test() {
  let result_returning_function =
    result_returning_function(results: ["Hey", "There", "100", "2"])

  promptly.new_internal("Give me any int", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.prompt
  |> should.equal(100)
}

pub fn promptly_int_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["0", "2", "3", "4"])

  promptly.new_internal("Give me an odd int", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_validator(int.is_odd)
  |> promptly.prompt
  |> should.equal(3)
}

pub fn promptly_float_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.new_internal("Give me any float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_float
  |> promptly.prompt
  |> should.equal(0.0)
}

pub fn promptly_float_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.new_internal("Give me any non-zero float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_float
  |> promptly.with_validator(fn(value) { value != 0.0 })
  |> promptly.prompt
  |> should.equal(3.14)
}

pub fn promptly_int_with_map_to_different_type_validator_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "2", "0.0", "3.14"])

  promptly.new_internal("Give me any non-zero float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.as_int
  |> promptly.with_map_validator(fn(value) {
    case value {
      1 -> Ok("a")
      _ -> Ok("b")
    }
  })
  |> promptly.prompt
  |> should.equal("b")
}

fn result_returning_function(
  results results: List(a),
) -> fn(Int) -> Result(a, b) {
  fn(attempt) {
    let assert Some(result) = results |> at(index: attempt)
    Ok(result)
  }
}

fn at(items items: List(a), index index: Int) -> Option(a) {
  do_at(items:, index:)
}

fn do_at(items items: List(a), index index: Int) -> Option(a) {
  case items, index {
    _, index if index < 0 -> None
    [_, ..rest], index if index > 0 -> do_at(items: rest, index: index - 1)
    [item, ..], _ -> Some(item)
    [], _ -> None
  }
}
