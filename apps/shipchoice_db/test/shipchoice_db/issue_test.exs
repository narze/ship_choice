defmodule ShipchoiceDb.IssueTest do
  use ExUnit.Case
  import ShipchoiceDb.Factory
  alias ShipchoiceDb.{Repo, Issue}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
  end

  describe "insert/1" do
    test "inserts an issue" do
      issue_to_insert = %{
        shipment_number: "PORM0001",
      }

      {:ok, inserted_issue} = Issue.insert(issue_to_insert)

      issue = Issue.get(inserted_issue.id)

      assert issue.id == inserted_issue.id
      assert issue.shipment_number == inserted_issue.shipment_number
    end
  end

  describe "all/0" do
    test "gets all issues" do
      issues = Issue.all

      assert length(issues) == 0
    end
  end

  describe "get_shipment/1" do
    test "gets issues' shipment by shipment number" do
      issue = insert(:issue, %{shipment_number: "PORM000188508"})
      shipment1 = insert(:shipment, %{shipment_number: "PORM000188508"})
      shipment2 = insert(:shipment, %{shipment_number: "PORM000188509"})

      assert shipment1 == Issue.get_shipment(issue)
    end
  end
end
