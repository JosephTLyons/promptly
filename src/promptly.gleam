import gleam/bool
import gleam/float
import gleam/int
import gleam/result
import input
import persevero

pub fn int_input(prompt: String) -> Int {
  let operation = fn() { prompt |> input.input |> result.try(int.parse) }
  retry(operation)
}

pub fn float_input(prompt: String) -> Float {
  let operation = fn() { prompt |> input.input |> result.try(float.parse) }
  retry(operation)
}

pub fn text_input(prompt: String) -> String {
  let operation = fn() { prompt |> input.input }
  retry(operation)
}

pub fn choice(prompt: String, is_valid_option: fn(String) -> Bool) -> String {
  let operation = fn() {
    use input <- result.try(input.input(prompt))
    use <- bool.guard(is_valid_option(input), Error(Nil))
    Ok(input)
  }
  retry(operation)
}

fn retry(operation: fn() -> Result(a, b)) -> a {
  let assert Ok(value) =
    persevero.execute(
      wait_stream: persevero.no_backoff(),
      allow: persevero.all_errors,
      // persevero doesn't have an `Endless` mode
      mode: persevero.MaxAttempts(10_000_000),
      operation:,
    )

  value
}
