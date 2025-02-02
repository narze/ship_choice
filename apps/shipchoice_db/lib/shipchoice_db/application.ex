defmodule ShipchoiceDb.Application do
  @moduledoc """
  The ShipchoiceDb Application Service.

  The shipchoice_db system business domain lives in this application.

  Exposes API to clients such as the `ShipchoiceDbWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(ShipchoiceDb.Repo, []),
    ], strategy: :one_for_one, name: ShipchoiceDb.Supervisor)
  end
end
