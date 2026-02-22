defmodule ConcurrentScraper.HtmlParser do
  @moduledoc """
  HTML Parser — Extract links and titles from HTML strings.

  Uses simple regex/string parsing (no external HTML library needed).
  Handles basic HTML with <a href="..."> links and <title> tags.

  Hint: Start with extract_title, then extract_links, then extract_page_info.
  """

  @doc """
  Extract the page title from an HTML string.
  Returns the text inside the first <title>...</title> tag, or nil if none found.

  ## Examples

      iex> ConcurrentScraper.HtmlParser.extract_title("<html><title>Hello</title></html>")
      "Hello"

      iex> ConcurrentScraper.HtmlParser.extract_title("<html></html>")
      nil
  """
  @spec extract_title(String.t()) :: String.t() | nil
  def extract_title(_html) do
    raise "Implement extract_title"
  end

  @doc """
  Extract all href values from <a> tags in the HTML.
  Returns a list of URL strings.

  ## Examples

      iex> html = ~s(<a href="https://example.com">Link</a><a href="/about">About</a>)
      iex> ConcurrentScraper.HtmlParser.extract_links(html)
      ["https://example.com", "/about"]
  """
  @spec extract_links(String.t()) :: [String.t()]
  def extract_links(_html) do
    raise "Implement extract_links"
  end

  @doc """
  Resolve a relative URL against a base URL.

  ## Examples

      iex> ConcurrentScraper.HtmlParser.resolve_url("/about", "https://example.com/page")
      "https://example.com/about"

      iex> ConcurrentScraper.HtmlParser.resolve_url("https://other.com", "https://example.com")
      "https://other.com"
  """
  @spec resolve_url(String.t(), String.t()) :: String.t()
  def resolve_url(_url, _base_url) do
    raise "Implement resolve_url"
  end

  @doc """
  Extract all information from an HTML page: title, links, and link texts.
  Links should be resolved against the base URL.

  Returns a map with:
    - :title — the page title (or nil)
    - :links — list of resolved absolute URLs
    - :link_texts — list of {url, text} tuples

  ## Examples

      iex> html = ~s(<html><title>Home</title><body><a href="/about">About Us</a></body></html>)
      iex> ConcurrentScraper.HtmlParser.extract_page_info(html, "https://example.com")
      %{title: "Home", links: ["https://example.com/about"], link_texts: [{"https://example.com/about", "About Us"}]}
  """
  @spec extract_page_info(String.t(), String.t()) :: map()
  def extract_page_info(_html, _base_url) do
    raise "Implement extract_page_info"
  end
end
