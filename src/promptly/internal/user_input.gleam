import input

pub type InputStatus {
  Provided
  NotProvided
}

pub fn input(text: String) -> #(Result(String, Nil), InputStatus) {
  input_internal(text, input.input)
}

pub fn input_internal(
  text: String,
  input_function: fn(String) -> Result(String, Nil),
) -> #(Result(String, Nil), InputStatus) {
  let input = input_function(text)
  let input_status = case input {
    Ok("") -> NotProvided
    Error(_) -> NotProvided
    _ -> Provided
  }
  #(input, input_status)
}
