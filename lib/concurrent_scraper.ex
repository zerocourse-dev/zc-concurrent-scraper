defmodule ConcurrentScraper do
  @moduledoc """
  Concurrent Web Scraper in Elixir.

  A web scraper that fetches multiple pages concurrently using Task.async_stream,
  parses HTML to extract links and titles, uses a GenServer to track visited URLs
  and prevent revisits, and limits concurrency.

  ## Architecture

  - `ConcurrentScraper.HtmlParser` — Parse HTML strings to extract links and titles
  - `ConcurrentScraper.UrlTracker` — GenServer to track visited URLs
  - `ConcurrentScraper.Scraper` — Orchestrator with concurrent fetching

  ## Usage

      # Start the URL tracker
      {:ok, tracker} = ConcurrentScraper.UrlTracker.start_link()

      # Scrape with a custom fetch function (for testing/flexibility)
      fetcher = fn url -> {:ok, "<html>...</html>"} end
      results = ConcurrentScraper.Scraper.crawl("https://example.com", fetcher,
        tracker: tracker, max_depth: 2, max_concurrency: 5)

      # Export results as JSON
      json = ConcurrentScraper.Scraper.to_json(results)
  """
end
