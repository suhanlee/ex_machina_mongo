defmodule ExMachinaMongo do
  defmacro __using__(opts) do
    verify_mongo_repo_dep()

    quote do
      use ExMachina
      use ExMachinaMongo.Strategy, repo: unquote(Keyword.get(opts, :repo))

      def params_for(factory_name, attrs \\ %{}) do
        ExMachinaMongo.params_for(__MODULE__, factory_name, attrs)
      end

      def string_params_for(factory_name, attrs \\ %{}) do
        ExMachinaMongo.string_params_for(__MODULE__, factory_name, attrs)
      end
    end
  end

  defp verify_mongo_repo_dep() do
    unless Code.ensure_loaded?(Mongo.Repo) do
      raise "You tried to use ExMachinaMongo, but the Mongo.Repo module is not loaded. " <>
              "Please add ecto to your dependencies."
    end
  end

  def params_for(factory_module, factory_name, attrs \\ %{}) do
    %{__struct__: module} = document = factory_module.build(factory_name, attrs)
    module.dump(document)
  end

  def string_params_for(factory_module, factory_name, attrs \\ %{}) do
    %{__struct__: module} = document = factory_module.build(factory_name, attrs)

    document
    |> Poison.encode!()
    |> Poison.decode!()
  end
end
