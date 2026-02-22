defmodule ConcurrentScraper.UrlTracker do
  @moduledoc """
  URL Tracker — GenServer to track visited URLs and prevent revisits.

  Maintains a set of visited URLs. Provides atomic "visit if not visited"
  operations to prevent race conditions in concurrent scraping.

  Hint: Start with start_link/init, then visited?/mark_visited, then visit_if_new.
  """
  use GenServer

  # ── Client API ──

  @doc """
  Start the UrlTracker GenServer.
  Accepts an optional list of already-visited URLs.

  ## Examples

      iex> {:ok, pid} = ConcurrentScraper.UrlTracker.start_link()
      iex> is_pid(pid)
      true
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(_opts \\ []) do
    raise "Implement start_link"
  end

  @doc """
  Check if a URL has been visited.

  ## Examples

      iex> {:ok, pid} = ConcurrentScraper.UrlTracker.start_link()
      iex> ConcurrentScraper.UrlTracker.visited?(pid, "https://example.com")
      false
  """
  @spec visited?(GenServer.server(), String.t()) :: boolean()
  def visited?(_tracker, _url) do
    raise "Implement visited?"
  end

  @doc """
  Mark a URL as visited.

  ## Examples

      iex> {:ok, pid} = ConcurrentScraper.UrlTracker.start_link()
      iex> ConcurrentScraper.UrlTracker.mark_visited(pid, "https://example.com")
      :ok
  """
  @spec mark_visited(GenServer.server(), String.t()) :: :ok
  def mark_visited(_tracker, _url) do
    raise "Implement mark_visited"
  end

  @doc """
  Atomically check and mark a URL as visited.
  Returns :ok if the URL was not yet visited (and is now marked),
  or :already_visited if it was already tracked.

  This atomic operation prevents race conditions where two concurrent
  tasks both check and then both try to visit the same URL.

  ## Examples

      iex> {:ok, pid} = ConcurrentScraper.UrlTracker.start_link()
      iex> ConcurrentScraper.UrlTracker.visit_if_new(pid, "https://example.com")
      :ok
      iex> ConcurrentScraper.UrlTracker.visit_if_new(pid, "https://example.com")
      :already_visited
  """
  @spec visit_if_new(GenServer.server(), String.t()) :: :ok | :already_visited
  def visit_if_new(_tracker, _url) do
    raise "Implement visit_if_new"
  end

  @doc """
  Return all visited URLs.

  ## Examples

      iex> {:ok, pid} = ConcurrentScraper.UrlTracker.start_link()
      iex> ConcurrentScraper.UrlTracker.mark_visited(pid, "https://example.com")
      iex> ConcurrentScraper.UrlTracker.all_visited(pid)
      ["https://example.com"]
  """
  @spec all_visited(GenServer.server()) :: [String.t()]
  def all_visited(_tracker) do
    raise "Implement all_visited"
  end

  @doc """
  Return the count of visited URLs.
  """
  @spec count(GenServer.server()) :: non_neg_integer()
  def count(_tracker) do
    raise "Implement count"
  end

  @doc """
  Reset the tracker, clearing all visited URLs.
  """
  @spec reset(GenServer.server()) :: :ok
  def reset(_tracker) do
    raise "Implement reset"
  end

  # ── Server Callbacks ──
  # Implement init/1, handle_call/3, and handle_cast/2 as needed.

  @impl true
  def init(_opts) do
    raise "Implement init"
  end
end
