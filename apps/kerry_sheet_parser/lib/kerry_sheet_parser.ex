defmodule KerrySheetParser do
  @moduledoc """
  Documentation for KerrySheetParser.
  """
  @keys [
    :consignment_no,
    nil,
    :date_time,
    nil,
    nil,
    nil,
    nil,
    :payer,
    :sender,
    :route,
    :dc,
    :svc_type,
    :pkg_count,
    :last_status_code,
    :dly_status_code,
    nil,
    nil,
    nil,
    :dly_status_remark,
    nil,
    :station_location,
    :cod_amount,
  ]

  def parse_pending_sheet(sheet_path) do
    sheet_number = 0
    start_row = 0

    data = Excelion.parse!(sheet_path, sheet_number, start_row)

    rows =
      data
      |> Enum.drop(14) # Drop rows until first row of data
      |> Enum.drop(-1) # Drop summary row at the bottom
      |> Enum.map(fn row ->
        row =
          row
          |> Enum.map(fn cell ->
            cell
            |> String.replace_prefix("\"", "")
            |> String.replace_suffix("\"", "")
            |> String.replace("\n", "")
          end)

        @keys
        |> Enum.zip(row)
        |> Enum.into(%{})
        |> Map.delete(nil)
      end)

    {:ok, rows}
  end
end
