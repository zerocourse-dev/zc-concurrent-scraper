defmodule ConcurrentScraper.HtmlParserTest do
  use ExUnit.Case, async: true

  alias ConcurrentScraper.HtmlParser

  describe "extract_title/1" do
    test "extracts title from basic HTML" do
      html = "<html><head><title>My Page</title></head><body></body></html>"
      assert HtmlParser.extract_title(html) == "My Page"
    end

    test "returns nil when no title tag exists" do
      html = "<html><head></head><body>Hello</body></html>"
      assert HtmlParser.extract_title(html) == nil
    end

    test "handles title with whitespace" do
      html = "<title>  Spaced Title  </title>"
      assert HtmlParser.extract_title(html) == "Spaced Title"
    end

    test "handles empty title" do
      html = "<title></title>"
      assert HtmlParser.extract_title(html) == nil
    end
  end

  describe "extract_links/1" do
    test "extracts href from anchor tags" do
      html = ~s(<a href="https://example.com">Link</a>)
      assert HtmlParser.extract_links(html) == ["https://example.com"]
    end

    test "extracts multiple links" do
      html = ~s(<a href="/page1">One</a><a href="/page2">Two</a><a href="/page3">Three</a>)
      assert HtmlParser.extract_links(html) == ["/page1", "/page2", "/page3"]
    end

    test "handles single-quoted hrefs" do
      html = ~s(<a href='/about'>About</a>)
      assert HtmlParser.extract_links(html) == ["/about"]
    end

    test "returns empty list when no links" do
      html = "<html><body>No links here</body></html>"
      assert HtmlParser.extract_links(html) == []
    end

    test "ignores anchor-only links" do
      html = ~s(<a href="#section">Jump</a><a href="https://example.com">Real</a>)
      links = HtmlParser.extract_links(html)
      assert "https://example.com" in links
    end
  end

  describe "resolve_url/2" do
    test "returns absolute URLs unchanged" do
      assert HtmlParser.resolve_url("https://other.com/page", "https://example.com") ==
               "https://other.com/page"
    end

    test "resolves root-relative URLs" do
      assert HtmlParser.resolve_url("/about", "https://example.com/page/sub") ==
               "https://example.com/about"
    end

    test "resolves relative URLs" do
      assert HtmlParser.resolve_url("page2", "https://example.com/dir/page1") ==
               "https://example.com/dir/page2"
    end

    test "handles base URL with trailing slash" do
      assert HtmlParser.resolve_url("/contact", "https://example.com/") ==
               "https://example.com/contact"
    end
  end

  describe "extract_page_info/2" do
    test "extracts title, links, and link texts" do
      html = """
      <html>
        <head><title>Home Page</title></head>
        <body>
          <a href="/about">About Us</a>
          <a href="https://blog.example.com">Blog</a>
        </body>
      </html>
      """

      info = HtmlParser.extract_page_info(html, "https://example.com")
      assert info.title == "Home Page"
      assert "https://example.com/about" in info.links
      assert "https://blog.example.com" in info.links
      assert length(info.link_texts) == 2
    end

    test "handles page with no links" do
      html = "<html><title>Empty</title><body>Nothing</body></html>"
      info = HtmlParser.extract_page_info(html, "https://example.com")
      assert info.title == "Empty"
      assert info.links == []
      assert info.link_texts == []
    end

    test "resolves relative links against base URL" do
      html = ~s(<html><body><a href="/page">Link</a></body></html>)
      info = HtmlParser.extract_page_info(html, "https://example.com")
      assert info.links == ["https://example.com/page"]
    end
  end
end
