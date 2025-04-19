import gleam/float
import gleam/int
import gleam/result
import input

pub fn int_input(prompt: String) -> Int {
  number_input(prompt, int.parse)
}

pub fn float_input(prompt: String) -> Float {
  number_input(prompt, float.parse)
}

pub fn text_input(prompt: String) -> String {
  let func = fn() { input.input(prompt) }
  retry(func)
}

fn number_input(prompt: String, parse: fn(String) -> Result(a, Nil)) -> a {
  let func = fn() { prompt |> input.input |> result.try(parse) }
  retry(func)
}

fn retry(func: fn() -> Result(a, b)) -> a {
  case func() {
    Ok(value) -> value
    Error(_) -> retry(func)
  }
}
