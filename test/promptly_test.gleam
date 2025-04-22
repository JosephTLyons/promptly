import gleam/option.{Some}
import gleeunit
import gleeunit/should
import promptly

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn default_formatter_test() {
  promptly.default_formatter("Hey")(Some("Oops"))
  |> should.equal("Error: Oops\nHey")
}
