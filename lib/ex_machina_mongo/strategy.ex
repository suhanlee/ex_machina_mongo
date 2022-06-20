defmodule ExMachinaMongo.Strategy do
  use ExMachina.Strategy, function_name: :insert

  def handle_insert(_, %{repo: nil}) do
    raise_missing_repo_error()
  end

  def handle_insert(%{__struct__: module} = document, %{repo: repo}) do
    insert!(module, document, repo, [])
  end

  def handle_insert(document, %{repo: _repo}) do
    raise_not_a_collection_error(document)
  end

  def handle_insert(_document, %{repo: nil}, _opts) do
    raise_missing_repo_error()
  end

  def handle_insert(%{__struct__: module} = document, %{repo: repo}, opts) do
    insert!(module, document, repo, opts)
  end

  def handle_insert(document, %{repo: _repo}, _) do
    raise_not_a_collection_error(document)
  end

  defp raise_missing_repo_error() do
    raise """
    insert/1, insert/2 and insert/3 are not available unless you provide the :repo option. Example:
    use ExMachinaMongo, repo: MyApp.Repo
    """
  end

  defp raise_not_a_collection_error(document) do
    raise ArgumentError, "#{inspect(document)} is not a Mongo.Collection. Use `build` instead"
  end

  defp insert!(module, document, repo, opts) do
    if Kernel.function_exported?(module, :__collection__, 1) do
      repo.insert!(document, opts)
    else
      raise_not_a_collection_error(document)
    end
  end
end
