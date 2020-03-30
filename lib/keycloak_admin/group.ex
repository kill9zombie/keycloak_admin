defmodule KeycloakAdmin.Groups do
  @spec from_maps([Map.t()]) :: {:ok[KeycloakAdmin.Group.t()]}
  def from_maps(maps) do
    groups =
      Enum.reduce(maps, [], fn group_map ->
        KeycloakAdmin.Group.from_map(group_map)
      end)

    if Enum.any?(groups, fn {:error, _} -> true end) do
      reasons = for {:error, reason} <- groups, do: reason
      {:error, reasons}
    else
      {:ok, groups}
    end
  end
end

defmodule KeycloakAdmin.Group do
  defstruct [:id, :name, :path]

  def from_map(map) do
    struct_keys = Map.keys(%__MODULE__{})

    if Enum.all?(struct_keys, fn key -> key in Map.keys(map) end) do
      # yay!
      struct =
        Enum.reduce(struct_keys, %__MODULE__{}, fn key, acc ->
          Map.update(acc, key, Map.get(map, key))
        end)

      {:ok, struct}
    else
      {:error,
       "Could not build a #{__MODULE__}, expected keys: #{inspect(struct_keys)} but only got: #{
         inspect(Map.keys(map))
       }"}
    end
  end
end
