defmodule Telegraph.Util.Json2Markdown do
  def to_markdown(json) do
    %{
      :json => json,
      :content => json["content"] |> parse |> beautify |> to_markdown_string(json)
    }
  end

  defp to_markdown_string(content, json) do
    """
    ---
    title: #{json["title"]}
    published: false
    description: #{String.slice(json["description"], 0..100) |> String.trim()}...
    tags: 
    //author: #{json["author_name"]}
    //author_url: #{json["author_url"]}
    //cover_image: https://direct_url_to_image.jpg
    ---

    #{content}
    """
  end

  defp beautify(items) do
    Enum.map(items, fn item ->
      item
      |> String.replace_prefix("{{spaceIfNotFirstChar}}", "")
      |> String.replace("{{spaceIfNotFirstChar}}", "{{space}}")
      |> String.replace("{{space}}", " ")
      |> String.replace("{{newline}}", "\n")
    end)
    |> Enum.join("\n\n")
  end

  defp parse(content) do
    Enum.map(content, fn item ->
      case is_binary(item) do
        true -> item |> String.trim()
        false -> item |> transform |> String.trim()
      end
    end)
  end

  defp children(item) do
    case is_binary(item) do
      true ->
        item |> String.trim()

      false ->
        case item["children"] do
          nil -> ""
          children -> children |> parse
        end
    end
  end

  defp transform(item) do
    # Name of the DOM element. Available tags: a, aside, b, 
    # blockquote, br, code, em, figcaption, figure, h3, h4, hr, i, 
    # iframe, img, li, ol, p, pre, s, strong, u, ul, video.
    case item["tag"] do
      "img" ->
        """
            ![#{children(item)}](#{Telegraph.url()}#{item["attrs"]["src"]})
        """

      "figcaption" ->
        """
            <figcaption>#{children(item)}</figcaption>
        """

      "figure" ->
        """
            <figure>#{children(item)}</figure>
        """

      "br" ->
        "\n"

      "p" ->
        """
            #{children(item)}
        """

      "aside" ->
        """
            <aside>#{children(item)}</aside>
        """

      "blockquote" ->
        """
            > #{children(item)}
        """

      "code" ->
        """
            ```
            #{children(item)}
            ```
        """

      "h1" ->
        """
            # #{children(item)}
        """

      "h2" ->
        """
            ## #{children(item)}
        """

      "h3" ->
        """
            ### #{children(item)}
        """

      "h4" ->
        """
            #### #{children(item)}
        """

      "h5" ->
        """
            ##### #{children(item)}
        """

      "h6" ->
        """
            ###### #{children(item)}
        """

      "iframe" ->
        """
            {% embed #{item["attrs"]["src"]} #{children(item)} %}
        """

      "li" ->
        """
            * #{children(item)}{{newline}}{{newline}}
        """

      "ol" ->
        """
            . #{children(item)}{{newline}}{{newline}}
        """

      "ul" ->
        """
            #{children(item)}
        """

      "pre" ->
        """
            <pre>#{children(item)}</pre>
        """

      "video" ->
        """
            <video>#{children(item)}</video>
        """

      "source" ->
        """
            <source src="#{item["attrs"]["src"]}">
        """

      "s" ->
        """
            <s>#{children(item)}</s>
        """

      "u" ->
        """
            <u>#{children(item)}</u>
        """

      "i" ->
        """
            {{spaceIfNotFirstChar}}_#{children(item)}_{{space}}
        """

      "em" ->
        """
            {{spaceIfNotFirstChar}}_#{children(item)}_{{space}}
        """

      "a" ->
        """
            {{spaceIfNotFirstChar}}[#{children(item)}](#{item["attrs"]["href"]}){{space}}
        """

      "strong" ->
        """
            {{spaceIfNotFirstChar}}**#{children(item)}**{{space}}
        """

      "b" ->
        """
            {{spaceIfNotFirstChar}}**#{children(item)}**{{space}}
        """

      text ->
        text
    end
  end
end
