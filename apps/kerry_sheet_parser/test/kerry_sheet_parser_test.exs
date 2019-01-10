defmodule KerrySheetParserTest do
  use ExUnit.Case
  doctest KerrySheetParser

  describe "parse_pending_sheet/1" do
    test "returns array of maps" do
      sheet_path = "test/fixtures/HPPY_Pending-3-11-61.xlsx"
      {:ok, result} = KerrySheetParser.parse_pending_sheet(sheet_path)

      assert 92 == result |> length()

      first_row = result |> Enum.at(0)

      assert result |> is_list()
      assert first_row[:cod_amount]
      assert first_row[:consignment_no] == "HPPY001114541"
      assert first_row[:date_time]
      assert first_row[:dc]
      assert first_row[:dly_status_code] == "DLY66"
      assert first_row[:last_status_code]
      assert first_row[:payer]
      assert first_row[:pkg_count]
      assert first_row[:route]
      assert first_row[:station_location]
      assert first_row[:svc_type]
      assert first_row[:sender] == "คุณเรวดี เอี่ยมสุนทรวิทย์ (คุณธฤตมน นวลตาลส่งแทน)  0816335441"
      assert first_row[:recipient] == "คุณ ดนัย เวศนารัตน์ 389 กลางเวียง อำเภอเวียงสา น่าน  0949189035"
      assert first_row[:sender_and_recipient] == nil

      refute first_row[nil]
    end
  end
end
