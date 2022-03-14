defmodule Telegraph.Markdown.Test do
  alias Telegraph.Test.Fixtures
  alias Telegraph.Util.Json2Markdown

  use ExUnit.Case
  doctest Telegraph

  test "that data is present in output object" do
    json = Fixtures.load_json_fixture()
    data = Json2Markdown.to_markdown(json)
    assert data[:json] != nil
    assert data[:content] != nil
  end
end
