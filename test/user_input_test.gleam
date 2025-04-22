import gleeunit/should
import promptly/internal/user_input.{NotProvided, Provided}

pub fn input_test() {
  user_input.input_internal("", Ok) |> should.equal(#(Ok(""), NotProvided))
  user_input.input_internal("Hey", Ok) |> should.equal(#(Ok("Hey"), Provided))
  user_input.input_internal("Nope", fn(_) { Error(Nil) })
  |> should.equal(#(Error("Failed to get user input."), NotProvided))
}
