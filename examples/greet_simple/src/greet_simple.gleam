import gleam/io
import promptly

pub fn main() -> Nil {
  let name = promptly.new() |> promptly.prompt(fn(_) { "Name: " })
  io.println("Hello, " <> name)
}
