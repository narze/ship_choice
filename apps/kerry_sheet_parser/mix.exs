defmodule KerrySheetParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :kerry_sheet_parser,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KerrySheetParser.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excelion, "~> 0.0.5"},
      {:xlsx_parser, github: "TheFirstAvenger/elixir-xlsx_parser", override: true},
      {:simple_agent, override: true},
      {:sweet_xml, override: true},
    ]
  end
end
