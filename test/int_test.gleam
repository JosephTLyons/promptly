import gleam/int
import gleeunit/should
import promptly
import promptly/utils.{default_formatter, response_generator}

pub fn int_test() {
  let response_generator =
    response_generator(responses: ["Hey", "There", "100", "2"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.prompt(default_formatter("Give me any int: "))
  |> should.equal(100)
}

pub fn int_with_validation_test() {
  let response_generator = response_generator(responses: ["0", "2", "3", "4"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_validator(fn(x) {
    case int.is_odd(x) {
      True -> Ok(x)
      False -> Error("Was even.")
    }
  })
  |> promptly.prompt(default_formatter("Give me an odd int: "))
  |> should.equal(3)
}

pub fn int_with_map_to_different_type_validator_test() {
  let response_generator =
    response_generator(responses: ["Dog", "2", "0.0", "3.14"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.with_validator(fn(x) {
    case x {
      1 -> Ok("a")
      _ -> Ok("b")
    }
  })
  |> promptly.prompt(default_formatter("Give me any non-zero float: "))
  |> should.equal("b")
}

pub fn int_with_default_and_no_input_test() {
  let response_generator = response_generator(responses: [""])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default("0")
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.prompt(default_formatter("Give me any int (default: 0): "))
  |> should.equal(0)
}

pub fn int_with_default_and_input_test() {
  let response_generator = response_generator(responses: ["1"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default("0")
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.prompt(default_formatter("Give me any int (default: 0): "))
  |> should.equal(1)
}

pub fn int_with_default_and_bad_input_and_then_no_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Only use default with no input
  let response_generator = response_generator(responses: ["dog", ""])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default("0")
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.prompt(default_formatter("Give me any int (default: 0): "))
  |> should.equal(0)
}

pub fn int_with_default_and_bad_input_and_then_good_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Second input is good, use that
  let response_generator = response_generator(responses: ["dog", "1"])

  promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
  |> promptly.with_default("0")
  |> promptly.as_int(fn(_) { "Could not parse to Int." })
  |> promptly.prompt(default_formatter("Give me any int (default: 0): "))
  |> should.equal(1)
}

pub fn int_prompt_once_test() {
  let response_generator = response_generator(responses: ["11", "9"])
  let error_message = fn(number) {
    int.to_string(number) <> " is greater than 10!"
  }

  let prompter =
    promptly.new_internal(fn(_, attempt) { response_generator(attempt) })
    |> promptly.with_default("0")
    |> promptly.as_int(fn(_) { "Could not parse to Int." })
    |> promptly.with_validator(fn(age) {
      case age <= 10 {
        True -> Ok(age)
        False -> Error(error_message(age))
      }
    })

  let prompt = "Give me any int (default: 0): "
  let assert Error("11 is greater than 10!") =
    prompter |> promptly.prompt_once_internal(prompt, 0)

  let assert Ok(9) = prompter |> promptly.prompt_once_internal(prompt, 1)
}
