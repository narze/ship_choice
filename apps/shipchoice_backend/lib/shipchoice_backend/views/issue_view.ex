defmodule ShipchoiceBackend.IssueView do
  use ShipchoiceBackend, :view
  import Scrivener.HTML
  alias ShipchoiceDb.Issue

  def resolved_at(%Issue{} = issue) do
    if issue.resolved_at do
      issue.resolved_at |> Timex.format!("{relative}", :relative)
    else
      "-"
    end
  end
end
