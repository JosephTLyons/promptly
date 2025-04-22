import gleam/result
import input

pub type InputStatus {
  Provided
  NotProvided
}

pub fn input(text: String) -> #(Result(String, String), InputStatus) {
  input_internal(text, input.input)
}

pub fn input_internal(
  text: String,
  input_function: fn(String) -> Result(String, Nil),
) -> #(Result(String, String), InputStatus) {
  let input =
    text |> input_function |> result.replace_error("Failed to get user input.")
  let input_status = case input {
    Ok("") -> NotProvided
    Error(_) -> NotProvided
    _ -> Provided
  }
  #(input, input_status)
}
