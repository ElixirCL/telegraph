defmodule Telegraph.Html.Test do
  alias Telegraph.Test.Fixtures
  alias Telegraph.Util.Json2HTML

  use ExUnit.Case
  doctest Telegraph

  test "that data is present in output" do
    json = Fixtures.load_json_fixture()
    data = Json2HTML.to_html(json)
    assert data[:json] != nil
    assert data[:content] != nil
  end
end
