defmodule Mix.Tasks.Migrations do
  use Mix.Task

  def run(_) do
    Links.MigrationRunner.run()
  end
end
