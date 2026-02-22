defmodule ConcurrentScraper.UrlTrackerTest do
  use ExUnit.Case, async: true

  alias ConcurrentScraper.UrlTracker

  setup do
    {:ok, tracker} = UrlTracker.start_link()
    %{tracker: tracker}
  end

  describe "start_link/1" do
    test "starts successfully" do
      {:ok, pid} = UrlTracker.start_link()
      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "starts with pre-visited URLs" do
      {:ok, pid} = UrlTracker.start_link(initial: ["https://example.com"])
      assert UrlTracker.visited?(pid, "https://example.com") == true
    end
  end

  describe "visited?/2" do
    test "returns false for unvisited URL", %{tracker: tracker} do
      assert UrlTracker.visited?(tracker, "https://example.com") == false
    end

    test "returns true for visited URL", %{tracker: tracker} do
      UrlTracker.mark_visited(tracker, "https://example.com")
      assert UrlTracker.visited?(tracker, "https://example.com") == true
    end
  end

  describe "mark_visited/2" do
    test "marks a URL as visited", %{tracker: tracker} do
      assert UrlTracker.mark_visited(tracker, "https://example.com") == :ok
      assert UrlTracker.visited?(tracker, "https://example.com") == true
    end

    test "is idempotent — marking twice doesn't error", %{tracker: tracker} do
      UrlTracker.mark_visited(tracker, "https://example.com")
      assert UrlTracker.mark_visited(tracker, "https://example.com") == :ok
    end
  end

  describe "visit_if_new/2" do
    test "returns :ok for new URL", %{tracker: tracker} do
      assert UrlTracker.visit_if_new(tracker, "https://example.com") == :ok
    end

    test "returns :already_visited for seen URL", %{tracker: tracker} do
      UrlTracker.visit_if_new(tracker, "https://example.com")
      assert UrlTracker.visit_if_new(tracker, "https://example.com") == :already_visited
    end

    test "marks the URL as visited atomically", %{tracker: tracker} do
      UrlTracker.visit_if_new(tracker, "https://example.com")
      assert UrlTracker.visited?(tracker, "https://example.com") == true
    end
  end

  describe "all_visited/1" do
    test "returns empty list initially", %{tracker: tracker} do
      assert UrlTracker.all_visited(tracker) == []
    end

    test "returns all visited URLs", %{tracker: tracker} do
      UrlTracker.mark_visited(tracker, "https://a.com")
      UrlTracker.mark_visited(tracker, "https://b.com")
      visited = UrlTracker.all_visited(tracker)
      assert length(visited) == 2
      assert "https://a.com" in visited
      assert "https://b.com" in visited
    end
  end

  describe "count/1" do
    test "returns 0 initially", %{tracker: tracker} do
      assert UrlTracker.count(tracker) == 0
    end

    test "returns correct count", %{tracker: tracker} do
      UrlTracker.mark_visited(tracker, "https://a.com")
      UrlTracker.mark_visited(tracker, "https://b.com")
      assert UrlTracker.count(tracker) == 2
    end
  end

  describe "reset/1" do
    test "clears all visited URLs", %{tracker: tracker} do
      UrlTracker.mark_visited(tracker, "https://example.com")
      UrlTracker.reset(tracker)
      assert UrlTracker.count(tracker) == 0
      assert UrlTracker.visited?(tracker, "https://example.com") == false
    end
  end
end
