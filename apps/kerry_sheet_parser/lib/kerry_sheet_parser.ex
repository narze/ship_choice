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
    :sender_and_recipient,
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

    temp_file = "/tmp/kerry_pending_#{:os.system_time(:seconds)}_#{:rand.uniform(100_000)}.xlsx"
    File.cp(sheet_path, temp_file)

    data = Excelion.parse!(temp_file, sheet_number, start_row)
    File.rm(temp_file)

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
            |> String.trim()
            |> String.replace("\n\n", " || ")
            |> String.replace("\n", " ")
          end)

        map =
          @keys
          |> Enum.zip(row)
          |> Enum.into(%{})
          |> Map.delete(nil)

        map
        |> Map.put(:sender, String.split(map[:sender_and_recipient], " || ") |> List.first |> String.trim)
        |> Map.put(:recipient, String.split(map[:sender_and_recipient], " || ") |> List.last |> String.trim)
        |> Map.delete(:sender_and_recipient)
      end)

    {:ok, rows}
  end
end
