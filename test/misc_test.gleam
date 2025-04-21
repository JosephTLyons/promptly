import gleeunit/should
import promptly
import promptly/utils.{result_returning_function}

pub fn multiple_with_defaults_test() {
  let result_returning_function = result_returning_function(results: [""])

  promptly.new_internal("Give me any text: ", fn(_, attempt) {
    result_returning_function(attempt)
  })
  |> promptly.with_default("Hey")
  |> promptly.with_default("Man")
  |> promptly.prompt
  |> should.equal("Hey")
}

// Super duper edge case - but should probably fix this at some pointwith_default_interal
// pub fn multiple_with_defaults_with_not_provided_as_initial_default_test() {
//   let result_returning_function = result_returning_function(results: [""])

//   promptly.new_internal("Give me any text: ", fn(_, attempt) {
//     result_returning_function(attempt)
//   })
//   |> promptly.with_default("")
//   |> promptly.with_default("Man")
//   |> promptly.prompt
//   |> should.equal("Man")
// }

pub fn date_uses_default_test() {
  let result_returning_function = result_returning_function(results: [""])
  let to_date_validator = utils.to_date_validator()
  let default = utils.Date(month: 1, day: 1, year: 1970)

  promptly.new_internal(
    "Give me a date (default: 01/01/1970): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_map_validator(to_date_validator)
  |> promptly.with_default(default)
  |> promptly.prompt
  |> should.equal(default)
}

pub fn date_does_not_use_default_test() {
  let result_returning_function =
    result_returning_function(results: ["04/12/1990"])
  let to_date_validator = utils.to_date_validator()

  promptly.new_internal(
    "Give me a date (default: 01/01/1970): ",
    fn(_, attempt) { result_returning_function(attempt) },
  )
  |> promptly.with_map_validator(to_date_validator)
  |> promptly.with_default(utils.Date(month: 1, day: 1, year: 1970))
  |> promptly.prompt
  |> should.equal(utils.Date(month: 4, day: 12, year: 1990))
}
