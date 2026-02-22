# Concurrent Web Scraper in Elixir

A ZeroCourse project for Course 3.4: Functional Programming (Week 10-12).

## What You'll Build

Build a concurrent web scraper in Elixir that fetches multiple pages simultaneously using `Task.async_stream`, parses HTML to extract links and titles, uses a `GenServer` to track visited URLs, and outputs results as JSON.

### HtmlParser
| Function | Description |
|----------|-------------|
| `extract_title(html)` | Get text from `<title>` tag |
| `extract_links(html)` | Get all `href` values from `<a>` tags |
| `resolve_url(url, base_url)` | Convert relative URLs to absolute |
| `extract_page_info(html, base_url)` | Extract title, links, and link texts |

### UrlTracker (GenServer)
| Function | Description |
|----------|-------------|
| `start_link(opts)` | Start the tracker process |
| `visited?(tracker, url)` | Check if URL was already visited |
| `mark_visited(tracker, url)` | Mark a URL as visited |
| `visit_if_new(tracker, url)` | Atomic check-and-mark (prevents race conditions) |
| `all_visited(tracker)` | List all visited URLs |
| `count(tracker)` / `reset(tracker)` | Count or clear visited URLs |

### Scraper
| Function | Description |
|----------|-------------|
| `scrape_page(url, fetcher)` | Fetch and parse a single page |
| `crawl(start_url, fetcher, opts)` | BFS crawl with concurrent fetching |
| `to_json(results)` | Export results as JSON |

## Getting Started

1. Install dependencies:
   ```bash
   mix deps.get
   ```

2. Run the tests (they will all fail initially):
   ```bash
   mix test
   ```

3. Implement the modules in order:
   - `lib/concurrent_scraper/html_parser.ex` — pure functions, no GenServer needed
   - `lib/concurrent_scraper/url_tracker.ex` — GenServer with MapSet state
   - `lib/concurrent_scraper/scraper.ex` — orchestrator using Task.async_stream

4. Run the tests again to check your progress.

## Tips

- Start with `HtmlParser` — it's pure functions with regex, no concurrency.
- For `UrlTracker`, your GenServer state is a `MapSet`. `visit_if_new` is the key operation — it atomically checks and marks in a single `handle_call`.
- For `Scraper.crawl`, use BFS: process one depth level at a time with `Task.async_stream`, collect new links, filter through `UrlTracker`, repeat.
- The `fetcher` function is injected for testability. Tests pass mock fetchers, not real HTTP.
- `Jason` is already in your dependencies for JSON encoding.

## Running Tests

```bash
mix test                          # Run all tests
mix test test/html_parser_test.exs  # Run one file
mix test --trace                  # Verbose output
```
