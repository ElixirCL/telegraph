defmodule Telegraph.Util.Json2HTML do
  def to_html(json) do
    %{
      :json => json,
      :content => parse_content(json["content"]) |> to_html_string(json)
    }
  end

  defp to_html_string(content, json) do
    """
    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="utf-8">
            <title>#{json["title"]}</title>

            <meta description="#{json["description"]}">
            
            <link rel="stylesheet" href="https://unpkg.com/sakura.css/css/sakura.css" media="screen" />
            <link rel="stylesheet" href="https://unpkg.com/sakura.css/css/sakura-dark.css" media="screen and (prefers-color-scheme: dark)" />
        </head>
        <body>
            <header>
                <h1>#{json["title"]}</h1>
                <address>
                    <a rel="author" href="#{json["author_url"]}" target="_blank">#{json["author_name"]}</a>
                </address>
            </header>
            <main>
                #{Enum.join(content, "\n")}
            </main>
        </body>
    </html>
    """
  end

  defp parse_content(content) do
    Enum.map(content, fn item ->
      case is_binary(item) do
        true -> item
        false -> transform(item)
      end
    end)
  end

  defp children(item) do
    case item["children"] do
      nil -> ""
      children -> parse_content(children)
    end
  end

  defp transform(item) do
    # Name of the DOM element. Available tags: a, aside, b, 
    # blockquote, br, code, em, figcaption, figure, h3, h4, hr, i, 
    # iframe, img, li, ol, p, pre, s, strong, u, ul, video.
    case item["tag"] do
      "img" ->
        """
            <img src="#{Telegraph.url()}#{item["attrs"]["src"]}">
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
        "<br/>"

      "p" ->
        """
            <p>#{children(item)}</p>
        """

      "a" ->
        """
            <a href="#{item["attrs"]["href"]}" target="#{item["attrs"]["target"]}">
                #{children(item)}
            </a>
        """

      "aside" ->
        """
            <aside>#{children(item)}</aside>
        """

      "strong" ->
        """
            <strong>#{children(item)}</strong>
        """

      "b" ->
        """
            <b>#{children(item)}</b>
        """

      "blockquote" ->
        """
            <blockquote>#{children(item)}</blockquote>
        """

      "code" ->
        """
            <code>#{children(item)}</code>
        """

      "em" ->
        """
            <em>#{children(item)}</em>
        """

      "h1" ->
        """
            <h1>#{children(item)}</h1>
        """

      "h2" ->
        """
            <h2>#{children(item)}</h2>
        """

      "h3" ->
        """
            <h3>#{children(item)}</h3>
        """

      "h4" ->
        """
            <h4>#{children(item)}</h4>
        """

      "h5" ->
        """
            <h5>#{children(item)}</h5>
        """

      "h6" ->
        """
            <h6>#{children(item)}</h6>
        """

      "i" ->
        """
            <i>#{children(item)}</i>
        """

      "iframe" ->
        """
            <iframe src="#{item["attrs"]["src"]}">#{children(item)}</iframe>
        """

      "li" ->
        """
            <li>#{children(item)}</li>
        """

      "ol" ->
        """
            <ol>#{children(item)}</ol>
        """

      "ul" ->
        """
            <ul>#{children(item)}</ul>
        """

      "pre" ->
        """
            <pre>#{children(item)}</pre>
        """

      "s" ->
        """
            <s>#{children(item)}</s>
        """

      "u" ->
        """
            <u>#{children(item)}</u>
        """

      "video" ->
        """
            <video>#{children(item)}</video>
        """

      "source" ->
        """
            <source src="#{item["attrs"]["src"]}">
        """

      text ->
        text
    end
  end
end
