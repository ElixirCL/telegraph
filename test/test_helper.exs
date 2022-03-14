ExUnit.start()
Telegraph.init()

defmodule Telegraph.Test.Fixtures do
  def load_json_fixture() do
    File.read!("#{__DIR__}/fixtures/page-fixture.json")
    |> Jason.decode!()
  end
end
