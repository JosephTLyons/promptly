import gleeunit/should
import promptly/internal/user_input

pub fn input_test() {
  user_input.input_internal("", Ok) |> should.equal(Ok(""))
  user_input.input_internal("Hey", Ok) |> should.equal(Ok("Hey"))
  user_input.input_internal("Nope", fn(value) { Ok(value) })
  |> should.equal(Ok("Nope"))
}
