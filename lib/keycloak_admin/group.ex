defmodule KeycloakAdmin.Group do
  @moduledoc ~S"""
  Group operations.

  """

  alias KeycloakAdmin.HTTP

  def details(client = %{error: err}) when err != nil, do: client
  def details(client) do
    query = URI.encode_query(%{"full" => true})
    do_details(client, query)
  end

  def details(client, search) do
    query = URI.encode_query(%{"full" => true, "search" => search})
    do_details(client, query)
  end

  defp do_details(client, query) do
    case HTTP.get(client, "/groups?#{query}") do
      {:ok, connref, decoded} -> %{client | connref: connref, groups: decoded}
      {:error, reason} -> %{client | error: reason}
    end
  end

  def get_id(client = %{error: err}, _group_name) when err != nil, do: client
  def get_id(%KeycloakAdmin.Client{groups: []} = client, group_name) do
    client
    |> details()
    |> get_id(group_name)
  end
  def get_id(%KeycloakAdmin.Client{groups: groups}, group_name) do
    groups
    |> Stream.filter(fn(x) -> x["name"] == group_name end)
    |> Stream.map(fn(x) -> x["id"] end)
    |> Enum.at(0)
  end

end
