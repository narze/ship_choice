defmodule ShipchoiceBackend.MembershipController do
  use ShipchoiceBackend, :controller

  alias ShipchoiceDb.Membership

  plug(:authenticate_user)

  def new(conn, _params) do
    changeset = Membership.changeset(%Membership{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"membership" => membership_to_insert}) do
    inserted_membership =
      membership_to_insert
      |> Membership.insert()

    case inserted_membership do
      {:ok, _membership} ->
        conn
        |> put_flash(:info, "Added New Membership.")
        |> redirect(to: "/users")

      _ ->
        conn
        |> put_flash(:error, "Error occurred")
        |> redirect(to: "/memberships/new")
    end
  end
end
