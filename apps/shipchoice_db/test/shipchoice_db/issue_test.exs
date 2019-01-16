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

  describe "insert_rows/1" do
    test "inserts list of issues" do
      issue_list = [
        %{
          consignment_no: "PORM000188508",
          date_time: "date_time1",
          payer: "payer1",
          sender: "sender1",
          recipient: "recipient1",
          route: "route1",
          dc: "dc1",
          svc_type: "svc_type1",
          pkg_count: "pkg_count1",
          last_status_code: "last_status_code1",
          dly_status_code: "dly_status_code1",
          dly_status_remark: "dly_status_remark1",
          station_location: "station_location1",
          cod_amount: "cod_amount1",
        },
        %{
          consignment_no: "PORM000188509",
          date_time: "date_time2",
          payer: "payer2",
          sender: "sender2",
          recipient: "recipient2",
          route: "route2",
          dc: "dc2",
          svc_type: "svc_type2",
          pkg_count: "pkg_count2",
          last_status_code: "last_status_code2",
          dly_status_code: "dly_status_code2",
          dly_status_remark: "dly_status_remark2",
          station_location: "station_location2",
          cod_amount: "cod_amount2",
        },
      ]

      {:ok, count: 2, new: 2} = Issue.insert_rows(issue_list)

      assert length(Issue.all()) == 2
    end
  end

  describe "parse/1" do
    test "parses row to insertable data" do
      issue_row = %{
        consignment_no: "PORM000188508",
        date_time: "date_time1",
        payer: "payer1",
        sender: "sender1",
        recipient: "recipient1",
        route: "route1",
        dc: "dc1",
        svc_type: "svc_type1",
        pkg_count: "pkg_count1",
        last_status_code: "last_status_code1",
        dly_status_code: "dly_status_code1",
        dly_status_remark: "dly_status_remark1",
        station_location: "station_location1",
        cod_amount: "cod_amount1",
      }

      expected_map = %{
        shipment_number: "PORM000188508",
        payer: "payer1",
        sender: "sender1",
        recipient: "recipient1",
        route: "route1",
        dc: "dc1",
        last_status_code: "last_status_code1",
        dly_status_code: "dly_status_code1",
        dly_status_remark: "dly_status_remark1",
        station_location: "station_location1",
        metadata: %{
          cod_amount: "cod_amount1",
          date_time: "date_time1",
          svc_type: "svc_type1",
          pkg_count: "pkg_count1",
        }
      }

      assert Issue.parse(issue_row) == expected_map
    end
  end

  describe "resolved?/1" do
    test "returns false when resolved_at is not present" do
      issue = insert(:issue)

      refute Issue.resolved?(issue)
    end

    test "returns true when resolved_at is present" do
      issue = insert(:issue, resolved_at: NaiveDateTime.utc_now())

      assert Issue.resolved?(issue)
    end
  end

  describe "update/2" do
    test "updates an issue" do
      issue = insert(:issue)
      now = NaiveDateTime.utc_now()

      {:ok, updated_issue} =
        Issue.update(issue, %{payer: "foo", resolved_at: now})

      assert updated_issue.payer == "foo"
      assert updated_issue.resolved_at == now |> NaiveDateTime.truncate(:second)
    end
  end
end
