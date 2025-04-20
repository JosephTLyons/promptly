import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleeunit
import gleeunit/should
import promptly

pub fn main() -> Nil {
  gleeunit.main()
}

// Examples do not run (they would lock on waiting for input), they just ensure
// the external api doesn't change while making changes to allow for testing
pub fn example_1() {
  fn() {
    let options = ["Danny", "Kayla", "Gina", "Emery"]
    let option_text = string.join(options, ", ")
    let prompt = "Who is my best friend? [" <> option_text <> "]: "

    prompt
    |> promptly.string
    |> promptly.with_validator(list.contains(options, _))
    |> promptly.run
  }
}

pub fn example_2() {
  fn() {
    let lower = 0
    let upper = 100
    let prompt =
      "Pick a number ["
      <> int.to_string(lower)
      <> ", "
      <> int.to_string(upper)
      <> "): "

    prompt
    |> promptly.int
    |> promptly.with_validator(fn(a) { a >= lower && a < upper })
    |> promptly.run
  }
}

pub fn example_3() {
  fn() {
    "Give me a non-zero float: "
    |> promptly.float
    |> promptly.with_validator(fn(a) { a != 0.0 })
    |> promptly.run
  }
}

pub fn promptly_int_test() {
  let result_returning_function =
    result_returning_function(results: ["Hey", "There", "100", "2"])

  promptly.int_internal("Give me any int", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.run
  |> should.equal(100)
}

pub fn promptly_int_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["0", "2", "3", "4"])

  promptly.int_internal("Give me an odd int", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_validator(int.is_odd)
  |> promptly.run
  |> should.equal(3)
}

pub fn promptly_float_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.float_internal("Give me any float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.run
  |> should.equal(0.0)
}

pub fn promptly_float_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "1", "0.0", "3.14"])

  promptly.float_internal("Give me any non-zero float", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_validator(fn(value) { value != 0.0 })
  |> promptly.run
  |> should.equal(3.14)
}

pub fn promptly_string_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.string_internal("Give me some text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.run
  |> should.equal("Dog")
}

pub fn promptly_string_with_validation_test() {
  let result_returning_function =
    result_returning_function(results: ["Dog", "Bear", "I'm a Mongoose!", "Cat"])

  promptly.string_internal("Give me long text", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_validator(fn(text) { string.length(text) > 10 })
  |> promptly.run
  |> should.equal("I'm a Mongoose!")
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
