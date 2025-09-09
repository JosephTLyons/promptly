import gleam/int
import promptly.{ValidationFailed}
import promptly/utils

pub fn int_test() {
  assert promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> "Hey"
        1 -> "There"
        2 -> "100"
        3 -> "2"
        _ -> panic
      }
      |> Ok
    })
    |> promptly.as_int(fn(_) { "Could not parse to Int!" })
    |> promptly.prompt(utils.default_formatter("Give me any int: "))
    == 100
}

pub fn int_with_validation_test() {
  assert promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> "0"
        1 -> "2"
        2 -> "3"
        3 -> "4"
        _ -> panic
      }
      |> Ok
    })
    |> promptly.as_int(fn(_) { "Could not parse to Int." })
    |> promptly.with_validator(fn(x) {
      case int.is_odd(x) {
        True -> Ok(x)
        False -> Error("Was even.")
      }
    })
    |> promptly.prompt(utils.default_formatter("Give me an odd int: "))
    == 3
}

pub fn int_with_map_to_different_type_validator_test() {
  assert promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> "Dog"
        1 -> "2"
        2 -> "0.0"
        3 -> "3.14"
        _ -> panic
      }
      |> Ok
    })
    |> promptly.as_int(fn(_) { "Could not parse to Int!" })
    |> promptly.with_validator(fn(x) {
      case x {
        1 -> Ok("a")
        _ -> Ok("b")
      }
    })
    |> promptly.prompt(utils.default_formatter("Give me any non-zero float: "))
    == "b"
}

pub fn int_with_default_and_no_input_test() {
  assert promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> ""
        _ -> panic
      }
      |> Ok
    })
    |> promptly.with_default("0")
    |> promptly.as_int(fn(_) { "Could not parse to Int!" })
    |> promptly.prompt(utils.default_formatter("Give me any int (default: 0): "))
    == 0
}

pub fn int_with_default_and_input_test() {
  assert promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> "1"
        _ -> panic
      }
      |> Ok
    })
    |> promptly.with_default("0")
    |> promptly.as_int(fn(_) { "Could not parse to Int!" })
    |> promptly.prompt(utils.default_formatter("Give me any int (default: 0): "))
    == 1
}

pub fn int_with_default_and_bad_input_and_then_no_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Only use default with no input
  assert promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> "dog"
        1 -> ""
        _ -> panic
      }
      |> Ok
    })
    |> promptly.with_default("0")
    |> promptly.as_int(fn(_) { "Could not parse to Int!" })
    |> promptly.prompt(utils.default_formatter("Give me any int (default: 0): "))
    == 0
}

pub fn int_with_default_and_bad_input_and_then_good_input_test() {
  // Don't use default with bad input, this should prompt user again
  // Second input is good, use that
  assert promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> "dog"
        1 -> "1"
        _ -> panic
      }
      |> Ok
    })
    |> promptly.with_default("0")
    |> promptly.as_int(fn(_) { "Could not parse to Int!" })
    |> promptly.prompt(utils.default_formatter("Give me any int (default: 0): "))
    == 1
}

pub fn int_prompt_once_test() {
  let error_message = fn(number) {
    int.to_string(number) <> " is greater than 10!"
  }

  let prompter =
    promptly.new_internal(fn(_, attempt) {
      case attempt {
        0 -> "11"
        1 -> "9"
        _ -> panic
      }
      |> Ok
    })
    |> promptly.with_default("0")
    |> promptly.as_int(fn(_) { "Could not parse to Int!" })
    |> promptly.with_validator(fn(age) {
      case age <= 10 {
        True -> Ok(age)
        False -> Error(error_message(age))
      }
    })

  let prompt = "Give me any int (default: 0): "
  let assert Error(ValidationFailed("11 is greater than 10!")) =
    prompter |> promptly.prompt_once_internal(prompt, 0)

  let assert Ok(9) = prompter |> promptly.prompt_once_internal(prompt, 1)
}
