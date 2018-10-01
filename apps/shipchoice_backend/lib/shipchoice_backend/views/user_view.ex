defmodule ShipchoiceBackend.UserView do
  use ShipchoiceBackend, :view
  import Scrivener.HTML
  alias ShipchoiceDb.{Credits, User}

  def is_admin(%User{} = user) do
    if user.is_admin do
      "Yes"
    else
      "No"
    end
  end

  def get_credits(%User{} = user) do
    Credits.get_user_credit(user)
  end
end
