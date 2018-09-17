defmodule ShipchoiceBackend.Auth do
  import Phoenix.Controller
  import Plug.Conn

  alias ShipchoiceDb.User
  alias ShipchoiceBackend.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn

      user = user_id && User.get(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be signed in to access that page.")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  def authorize_admin(conn, _opts) do
    if conn.assigns[:current_user] &&
       conn.assigns[:current_user].is_admin do
      conn
    else
      conn
      |> put_flash(:error, "Not allowed.")
      |> redirect(to: redirect_back_path(conn))
      |> halt()
    end
  end

  defp redirect_back_path(conn, alternative \\ "/") do
    path =
      conn
      |> get_req_header("referer")
      |> referrer()

    path || alternative
  end

  defp referrer([]), do: nil
  defp referrer([h|_]), do: h
end
