Argument labels of public functions?
README.md
gleam.toml
Publish

Try using yielder to mock user input and avoid polluting everything with amount
Example with date.
   - Start simple,
   - Add validator,
   - Add default

Clean up tests and add a test for each kind of int, float, and text
allow for printed text to be testable so we can ensure nothing in those code paths change
history
ansi color configuration
generic on error (again) to allow for matching on errors returned by try_prompt in custom prompt loops
investigate try_prompt - try implementing a custom loop and see what might be missing
  - Currently, we aren't passing in a previous error, so the formatter can't report errors, but maybe this level of customization should ask for a prompt formatter
