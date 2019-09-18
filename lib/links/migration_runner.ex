defmodule Links.MigrationRunner do
  def run() do
    [:poolboy, :moebius] |> Enum.each(&Application.ensure_all_started/1)
    Moebius.Db.start_link(Moebius.get_connection())

    IO.inspect("Starting Moebius migrations")

    last_known_migration_record = get_last_migration()
    last_known_migration = Integer.to_string(last_known_migration_record.version)

    IO.inspect(last_known_migration)
    {:ok, migration_files} = File.ls("db")

    migration_timestamps = migration_files_timestamps(migration_files)
    timestamps_filenames = Enum.zip(migration_timestamps, migration_files)

    IO.inspect(timestamps_filenames)

    filtered_timestamps_filenames =
      Enum.filter(timestamps_filenames, fn item -> elem(item, 0) > last_known_migration end)

    IO.inspect(filtered_timestamps_filenames)

    apply_pending_migrations(filtered_timestamps_filenames)
  end

  defp migration_files_timestamps(migration_files) do
    migration_files |> Enum.map(fn filename -> String.split(filename, "_") |> hd() end)
  end

  defp get_last_migration() do
    {:ok, last_version} =
      Moebius.Query.db(:schema_migrations)
      |> Moebius.Query.last(:version)
      |> Moebius.Db.run()

    last_version |> Enum.at(0)
  end

  defp apply_pending_migrations(migration_files_list) do
    Enum.sort(migration_files_list, fn a, b -> elem(a, 0) <= elem(b, 0) end)
    |> Enum.each(fn migration_file ->
      IO.inspect("Applying migration: #{elem(migration_file, 1)}")

      atomized_filename =
        elem(migration_file, 1)
        |> String.split(".sql")
        |> hd()
        |> String.to_atom()

      {:ok, result} =
        Moebius.Db.transaction(fn pid ->
          Moebius.Query.sql_file(atomized_filename) |> Moebius.Db.run(pid)

          Moebius.Query.db(:schema_migrations)
          |> Moebius.Query.insert(
            version: String.to_integer(elem(migration_file, 0)),
            inserted_at: NaiveDateTime.utc_now()
          )
          |> Moebius.Db.run(pid)
        end)

      IO.inspect("Result of migration:")
      IO.inspect(result)
    end)
  end
end
