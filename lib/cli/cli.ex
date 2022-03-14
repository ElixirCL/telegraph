defmodule Telegraph.CLI do
  require Logger

  @moduledoc """

  Telegraph CLI v1.0.0

  synopsis:
      Calls the Telegraph API.
  usage:
      $ ./telegraph {options} arg1 arg2 ...
  options:
      --path         Specifies the path of the post.
      --file         Specifies a json to convert.
      --json         Save the page as a json.
      --markdown     Save the page as markdown.
      --html         Save the page as html.
  """
  def main(args) do
    Telegraph.init()
    args |> parse |> run
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
    name = String.downcase(String.trim(path)) <> ".json"

    case Jason.encode!(data) do
      nil -> ""
      content -> File.write(name, content, [:write, {:encoding, :utf8}])
    end
  end

  defp save_markdown(data, path) do
    name = String.downcase(String.trim(path)) <> ".md"

    case Telegraph.Util.Json2Markdown.to_markdown(data) do
      nil -> ""
      file -> File.write(name, file[:content], [:write, {:encoding, :utf8}])
    end
  end

  defp save_html(data, path) do
    name = String.downcase(String.trim(path)) <> ".html"

    case Telegraph.Util.Json2HTML.to_html(data) do
      nil -> ""
      file -> File.write(name, file[:content], [:write, {:encoding, :utf8}])
    end
  end

  # MARK: - run
  defp run({[path: path, json: true], _, _}) do
    json(path) |> save_json(path)
  end

  defp run({[path: path, markdown: true], _, _}) do
    json(path) |> save_markdown(path)
  end

  defp run({[path: path, html: true], _, _}) do
    json(path) |> save_html(path)
  end

  defp run({[file: file], _, _}) do
    data = read_file(file)
    path = Path.basename(file, ".json")
    save_markdown(data, path)
    save_html(data, path)
  end

  defp run({[help: true], _, _}) do
    help()
  end

  defp run(_argv) do
    help()
  end
end
