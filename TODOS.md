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
still think we can have generic with_default in a way that always works, with some better system
investigate try_prompt - try implementing a custom loop and see what might be missing
  - Currently, we aren't passing in a previous error, so the formatter can't report errors, but maybe this level of customization should ask for a prompt formatter
Have all testing rely on try_prompt and remove complex attempt-index system?
