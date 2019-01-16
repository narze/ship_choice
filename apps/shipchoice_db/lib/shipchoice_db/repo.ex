defmodule ShipchoiceDb.Repo do
  use Ecto.Repo,
    otp_app: :shipchoice_db,
    adapter: Application.get_env(:shipchoice_db, ShipchoiceDb.Repo)[:adapter]
  use Scrivener, page_size: 50

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
