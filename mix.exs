defmodule ShipChoice.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:distillery, "~> 1.5", runtime: false},
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
