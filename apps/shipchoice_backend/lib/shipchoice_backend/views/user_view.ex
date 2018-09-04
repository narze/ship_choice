defmodule ShipchoiceBackend.UserView do
  use ShipchoiceBackend, :view
  import Scrivener.HTML
  alias ShipchoiceDb.User

  def is_admin(%User{} = user) do
    if user.is_admin do
      "Yes"
    else
      "No"
    end
  end
end
