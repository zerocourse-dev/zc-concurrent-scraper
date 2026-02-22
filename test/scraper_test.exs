defmodule ConcurrentScraper.ScraperTest do
  use ExUnit.Case, async: true

  alias ConcurrentScraper.Scraper

  # Mock fetcher that returns predefined HTML for known URLs
  defp mock_fetcher(pages) do
    fn url ->
      case Map.fetch(pages, url) do
        {:ok, html} -> {:ok, html}
        :error -> {:error, :not_found}
      end
    end
  end

  describe "scrape_page/2" do
    test "returns page info on success" do
      fetcher = fn _url -> {:ok, "<html><title>Test</title><body><a href=\"/link\">Link</a></body></html>"} end
      {:ok, info} = Scraper.scrape_page("https://example.com", fetcher)
      assert info.title == "Test"
      assert is_list(info.links)
    end

    test "returns error on fetch failure" do
      fetcher = fn _url -> {:error, :timeout} end
      assert {:error, :timeout} = Scraper.scrape_page("https://example.com", fetcher)
    end

    test "includes the URL in the result" do
      fetcher = fn _url -> {:ok, "<html><title>Page</title></html>"} end
      {:ok, info} = Scraper.scrape_page("https://example.com", fetcher)
      assert info.url == "https://example.com"
    end
  end

  describe "crawl/3" do
    test "scrapes the start URL at depth 0" do
      pages = %{
        "https://example.com" => "<html><title>Home</title></html>"
      }

      results = Scraper.crawl("https://example.com", mock_fetcher(pages), max_depth: 0)
      assert length(results) == 1
      assert hd(results).url == "https://example.com"
      assert hd(results).title == "Home"
      assert hd(results).depth == 0
    end

    test "follows links to depth 1" do
      pages = %{
        "https://example.com" =>
          ~s(<html><title>Home</title><body><a href="https://example.com/about">About</a></body></html>),
        "https://example.com/about" =>
          ~s(<html><title>About</title></html>)
      }

      results = Scraper.crawl("https://example.com", mock_fetcher(pages), max_depth: 1)
      urls = Enum.map(results, & &1.url)
      assert "https://example.com" in urls
      assert "https://example.com/about" in urls
    end

    test "does not revisit already-visited URLs" do
      pages = %{
        "https://example.com" =>
          ~s(<html><title>Home</title><body><a href="https://example.com/a">A</a></body></html>),
        "https://example.com/a" =>
          ~s(<html><title>A</title><body><a href="https://example.com">Home</a></body></html>)
      }

      results = Scraper.crawl("https://example.com", mock_fetcher(pages), max_depth: 3)
      urls = Enum.map(results, & &1.url)
      assert length(urls) == length(Enum.uniq(urls))
    end

    test "respects max_pages limit" do
      # Create a graph with many pages
      pages =
        for i <- 0..20, into: %{} do
          url = "https://example.com/page#{i}"
          links = for j <- (i + 1)..min(i + 3, 20), do: ~s(<a href="https://example.com/page#{j}">Page #{j}</a>)
          html = "<html><title>Page #{i}</title><body>#{Enum.join(links)}</body></html>"
          {url, html}
        end

      results = Scraper.crawl("https://example.com/page0", mock_fetcher(pages),
        max_depth: 10, max_pages: 5)
      assert length(results) <= 5
    end

    test "handles fetch errors gracefully" do
      fetcher = fn
        "https://example.com" ->
          {:ok, ~s(<html><title>Home</title><body><a href="https://example.com/broken">Broken</a></body></html>)}
        "https://example.com/broken" ->
          {:error, :timeout}
      end

      results = Scraper.crawl("https://example.com", fetcher, max_depth: 1)
      # Should still have at least the home page
      assert length(results) >= 1
      assert hd(results).url == "https://example.com"
    end

    test "records depth for each page" do
      pages = %{
        "https://example.com" =>
          ~s(<html><title>Home</title><body><a href="https://example.com/a">A</a></body></html>),
        "https://example.com/a" =>
          ~s(<html><title>A</title><body><a href="https://example.com/b">B</a></body></html>),
        "https://example.com/b" =>
          ~s(<html><title>B</title></html>)
      }

      results = Scraper.crawl("https://example.com", mock_fetcher(pages), max_depth: 2)
      depth_map = Map.new(results, fn r -> {r.url, r.depth} end)
      assert depth_map["https://example.com"] == 0
      assert depth_map["https://example.com/a"] == 1
      assert depth_map["https://example.com/b"] == 2
    end
  end

  describe "to_json/1" do
    test "returns valid JSON string" do
      results = [%{url: "https://example.com", title: "Home", links: [], depth: 0}]
      json = Scraper.to_json(results)
      assert is_binary(json)
      assert {:ok, decoded} = Jason.decode(json)
      assert is_list(decoded)
    end

    test "includes all result fields" do
      results = [%{url: "https://example.com", title: "Home", links: ["/about"], depth: 0}]
      json = Scraper.to_json(results)
      {:ok, [page]} = Jason.decode(json)
      assert page["url"] == "https://example.com"
      assert page["title"] == "Home"
      assert page["links"] == ["/about"]
      assert page["depth"] == 0
    end

    test "handles empty results" do
      json = Scraper.to_json([])
      assert {:ok, []} = Jason.decode(json)
    end
  end
end
