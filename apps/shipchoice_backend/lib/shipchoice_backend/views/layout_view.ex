defmodule ShipchoiceBackend.LayoutView do
  use ShipchoiceBackend, :view

  def yes_no(bool) do
    if bool do
      "Yes"
    else
      "No"
    end
  end
end
