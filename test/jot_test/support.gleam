import simplifile
import filepath
import gleam/list
import gleam/string
import gleam/io

pub type Example {
  Example(file: String, djot: String, html: String)
}

const cases_directory = "test/cases"

pub fn load_example_test_cases() -> List(Example) {
  let assert Ok(tests) = simplifile.list_contents(cases_directory)
  tests
  |> list.map(filepath.join(cases_directory, _))
  |> list.flat_map(load_and_parse_file)
}

fn load_and_parse_file(path: String) -> List(Example) {
  let assert Ok(content) = simplifile.read(path)
  content
  |> string.split("\n")
  |> parse(path, [])
}

fn parse(
  lines: List(String),
  path: String,
  examples: List(Example),
) -> List(Example) {
  case lines {
    [] -> list.reverse(examples)
    [delim, ..lines] -> {
      let #(example, lines) = parse_one(lines, delim, path)
      let lines = pop_empty(lines)
      parse(lines, path, [example, ..examples])
    }
  }
}

fn parse_one(
  lines: List(String),
  delim: String,
  path: String,
) -> #(Example, List(String)) {
  let #(djot, lines) = collect_until(lines, ".", "")
  let #(html, lines) = collect_until(lines, delim, "")
  let example = Example(path, djot, html)
  #(example, lines)
}

fn collect_until(
  lines: List(String),
  end: String,
  acc: String,
) -> #(String, List(String)) {
  case lines {
    [] -> #(acc, [])
    [line, ..lines] if line == end -> #(acc, lines)
    [line, ..lines] -> collect_until(lines, end, acc <> line <> "\n")
  }
}

fn pop_empty(lines: List(String)) -> List(String) {
  case lines {
    ["", ..lines] -> lines
    _ -> lines
  }
}
