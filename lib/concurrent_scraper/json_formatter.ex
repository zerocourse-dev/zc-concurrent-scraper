defmodule ConcurrentScraper.JsonFormatter do
  @moduledoc """
  ExUnit formatter that outputs RSpec-compatible JSON to test-results.json.
  Used by GitHub Actions CI for ZeroCourse grading pipeline.
  """
  use GenServer

  def init(_opts) do
    {:ok, %{examples: [], summary: nil}}
  end

  def handle_cast({:test_finished, %ExUnit.Test{} = test}, state) do
    example = %{
      description: test.name |> to_string(),
      full_description: "#{inspect(test.module)} #{test.name}",
      status: status(test.state),
      file_path: test.tags.file,
      line_number: test.tags.line,
      run_time: test.time / 1_000_000,
      exception: exception_info(test.state)
    }

    {:noreply, %{state | examples: [example | state.examples]}}
  end

  def handle_cast({:suite_finished, %{run: run, failures: failures}}, state) do
    total = length(state.examples)
    passed = Enum.count(state.examples, &(&1.status == "passed"))

    result = %{
      version: "ZeroCourse ExUnit JSON Formatter",
      examples: Enum.reverse(state.examples),
      summary: %{
        duration: run / 1_000_000,
        example_count: total,
        failure_count: failures,
        pending_count: total - passed - failures
      },
      summary_line: "#{total} examples, #{failures} failures"
    }

    File.write!("test-results.json", Jason.encode!(result, pretty: true))
    {:noreply, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  defp status(nil), do: "passed"
  defp status({:failed, _}), do: "failed"
  defp status({:skipped, _}), do: "pending"
  defp status({:excluded, _}), do: "pending"
  defp status({:invalid, _}), do: "failed"
  defp status(_), do: "failed"

  defp exception_info({:failed, failures}) do
    failures
    |> Enum.map(fn {_, %{message: msg}} -> msg; _ -> "unknown error" end)
    |> Enum.join("\n")
  rescue
    _ -> "test failed"
  end

  defp exception_info(_), do: nil
end
