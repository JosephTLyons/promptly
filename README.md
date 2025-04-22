# promptly

[![Package Version](https://img.shields.io/hexpm/v/promptly)](https://hex.pm/packages/promptly)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/promptly/)

```sh
gleam add promptly
```
```gleam
import gleam/io
import promptly

pub fn main() -> Nil {
  let name = promptly.new() |> promptly.prompt(fn(_) { "Name: " })
  io.println("Hello, " <> name)
  // Name: Joe
  // Hello, Joe
}
```
