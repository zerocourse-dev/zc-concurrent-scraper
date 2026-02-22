defmodule ConcurrentScraper.Scraper do
  @moduledoc """
  Scraper — Orchestrator for concurrent web scraping.

  Uses Task.async_stream for concurrent fetching with a configurable
  concurrency limit. Integrates HtmlParser for extraction and UrlTracker
  for deduplication.

  The `fetcher` function is injected for testability — in production you'd
  pass an HTTP client, in tests you pass a mock function.

  Hint: Start with scrape_page, then crawl (BFS with Task.async_stream),
  then to_json.
  """

  alias ConcurrentScraper.{HtmlParser, UrlTracker}

  @doc """
  Scrape a single page: fetch it, parse HTML, extract info.

  The fetcher function takes a URL and returns {:ok, html_string} or {:error, reason}.

  ## Examples

      iex> fetcher = fn _url -> {:ok, "<html><title>Hi</title></html>"} end
      iex> {:ok, info} = ConcurrentScraper.Scraper.scrape_page("https://example.com", fetcher)
      iex> info.title
      "Hi"
  """
  @spec scrape_page(String.t(), (String.t() -> {:ok, String.t()} | {:error, term()})) ::
          {:ok, map()} | {:error, term()}
  def scrape_page(_url, _fetcher) do
    raise "Implement scrape_page"
  end

  @doc """
  Crawl starting from a URL, following links up to max_depth.
  Uses Task.async_stream for concurrent fetching.

  Options:
    - :tracker — pid of a UrlTracker (will start one if not provided)
    - :max_depth — how many levels deep to follow links (default: 2)
    - :max_concurrency — max simultaneous fetches (default: 5)
    - :max_pages — maximum total pages to scrape (default: 50)

  Returns a list of page result maps, each containing:
    - :url — the page URL
    - :title — page title
    - :links — list of links found
    - :depth — at what depth this page was scraped

  ## Examples

      iex> fetcher = fn _url -> {:ok, "<html><title>Page</title></html>"} end
      iex> results = ConcurrentScraper.Scraper.crawl("https://example.com", fetcher, max_depth: 0)
      iex> length(results)
      1
  """
  @spec crawl(String.t(), (String.t() -> {:ok, String.t()} | {:error, term()}), keyword()) ::
          [map()]
  def crawl(_start_url, _fetcher, _opts \\ []) do
    raise "Implement crawl"
  end

  @doc """
  Convert crawl results to a JSON string.

  ## Examples

      iex> results = [%{url: "https://example.com", title: "Home", links: [], depth: 0}]
      iex> json = ConcurrentScraper.Scraper.to_json(results)
      iex> is_binary(json)
      true
  """
  @spec to_json([map()]) :: String.t()
  def to_json(_results) do
    raise "Implement to_json"
  end
end
