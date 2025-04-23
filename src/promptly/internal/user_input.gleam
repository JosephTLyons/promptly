import gleam/result
import input

pub fn input(text: String) -> Result(String, String) {
  input_internal(text, input.input)
}

pub fn input_internal(
  text: String,
  input_function: fn(String) -> Result(String, Nil),
) -> Result(String, String) {
  text |> input_function |> result.replace_error("Failed to get user input.")
}
