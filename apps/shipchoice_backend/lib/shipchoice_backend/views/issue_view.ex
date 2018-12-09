defmodule ShipchoiceBackend.IssueView do
  use ShipchoiceBackend, :view
  import Scrivener.HTML
  alias ShipchoiceDb.Issue

  def resolved_at(%Issue{} = issue) do
    if issue.resolved_at do
      abs =
        issue.resolved_at
        |> Timex.format!("%T %F", :strftime)
      rel =
        issue.resolved_at
        |> Timex.format!("({relative})", :relative)

      abs <> " " <> rel
    else
      "-"
    end
  end
end
