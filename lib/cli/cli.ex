defmodule Telegraph.CLI do
  require Logger

  @moduledoc """

  Telegraph CLI v1.0.2

  synopsis:
      Calls the Telegraph API.
  usage:
      $ ./telegraph url|options arg1 arg2 ...
  options:
      --path         Specifies the path of the post.
      --file         Specifies a json to convert.
      --json         Save the page as a json.
      --markdown     Save the page as markdown.
      --html         Save the page as html.
  """
  def main(args) do
    Telegraph.init()

    argv = parse(args)
    {options, items, _} = argv

    # Support the url as the first param
    # to extract the path.
    # Is important that the path comes first
    # since the pattern match would fail
    # otherwise
    options = case items do
      items when is_list(items) -> cond do
        # Extract the path from the url
        Enum.count(items) > 0 -> [path: Telegraph.clean(Enum.at(items, 0))]
        true -> []
        end
    end ++ options

    run(options)
  end

  defp parse(args) do
    options = [
      switches: [
        help: :boolean,
        path: :string,
        file: :string,
        json: :boolean,
        html: :boolean,
        markdown: :boolean
      ],
      aliases: [
        h: :html,
        p: :path,
        j: :json,
        m: :markdown,
        f: :file
      ]
    ]

    OptionParser.parse(args, options)
  end

  defp help() do
    IO.puts(@moduledoc)
  end

  defp json(path) do
    case Telegraph.Pages.get_with_content(path) do
      {:ok, json} ->
        json

      {:error, :timeout} ->
        Logger.error("Timeout. Wait a few seconds and try again.")
        %{}

      {:error, :notfound} ->
        Logger.error("Page Not Found.")
        %{}

      {:error, reason} ->
        Logger.error(reason)
        %{}
    end
  end

  defp read_file(name) do
    content = File.read!(name)
    Jason.decode!(content)
  end

  defp save_json(data, path) do
    name = "#{String.downcase(String.trim(path))}.json"
    content = Jason.encode!(data)
    File.write(name, content, [:write])
  end

  defp save_markdown(data, path) do
    name = "#{String.downcase(String.trim(path))}.md"
    file = Telegraph.Util.Json2Markdown.to_markdown(data)
    File.write(name, file[:content], [:write])
  end

  defp save_html(data, path) do
    name = "#{String.downcase(String.trim(path))}.html"
    file = Telegraph.Util.Json2HTML.to_html(data)
    File.write(name, file[:content], [:write])
  end

  # MARK: - run
  defp run(path: path, json: true) do
    json(path) |> save_json(path)
  end

  defp run(path: path, markdown: true) do
    json(path) |> save_markdown(path)
  end

  defp run(path: path, html: true) do
    json(path) |> save_html(path)
  end

  defp run(path: path, json: true, html: true, markdown: true) do
    data = json(path)
    save_json(data, path)
    save_markdown(data, path)
    save_html(data, path)
  end

  defp run(path: path, json: true, html: true) do
    data = json(path)
    save_json(data, path)
    save_html(data, path)
  end

  defp run(path: path, json: true, markdown: true) do
    data = json(path)
    save_json(data, path)
    save_markdown(data, path)
  end

  defp run(path: path, html: true, markdown: true) do
    data = json(path)
    save_markdown(data, path)
    save_html(data, path)
  end

  defp run(path: path) do
    data = json(path)
    save_json(data, path)
    save_markdown(data, path)
    save_html(data, path)
  end

  defp run(file: file) do
    data = read_file(file)
    path = Path.basename(file, ".json")
    save_markdown(data, path)
    save_html(data, path)
  end

  defp run(help: true) do
    help()
  end

  defp run(_argv) do
    help()
  end
end
