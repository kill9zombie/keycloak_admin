defmodule KeycloakAdmin.User do
  @moduledoc ~S"""
  Keycloak Admin User operations

  client
  |> User.create_user(alice)
  |> User.details()
  |> User.add_groups([admins])
  |> KeycloakAdmin.resolve_errors()

  .. or if the user already exists in Keycloak

  user = %KeycloakAdmin.User{username: "bob"}

  client
  |> User.details(user)
  |> User.add_groups([admins])

  """

  @derive {Jason.Encoder, only: [:attributes, :credentials, :email, :firstName, :lastName, :username, :enabled]}

  defstruct attributes: %{},
            credentials: [],
            email: "",
            firstName: "",
            lastName: "",
            username: "",
            enabled: true,
            details: %{}

  alias KeycloakAdmin.{HTTP, Client}

  @doc ~S"""
  Create a user

  Note that this won't add users into groups explicitly.
  Users will be put in groups from the server side if you have a default group list set.
  """
  def create_user(client, %__MODULE__{} = user) do
    case HTTP.post(client, "/users", user) do
      {:ok, connref, _decoded} -> %{client | connref: connref, user: user}
      {:error, reason} -> %{client | error: reason}
    end
  end

  defp merge_user_details(user, details) do
    Enum.reduce(Map.keys(user), %{user | details: details}, fn(struct_key, acc) ->
        if Map.has_key?(details, Atom.to_string(struct_key)) do
          Map.put(acc, struct_key, Map.fetch!(details, Atom.to_string(struct_key)))
        else
          acc
        end
    end)
  end

  def details(client = %{error: err}) when err != nil, do: client
  def details(client), do: details(client, client.user)

  def details(client, %__MODULE__{username: username} = user) do
    query = URI.encode_query(%{"username" => username, "max" => 1})
    with {:ok, connref, decoded_user} when length(decoded_user) == 1 <- HTTP.get(client, "/users?#{query}"),
         found_user <- hd(decoded_user),
         user_id when user_id != nil <- found_user["id"],
         {:ok, connref, decoded_groups} <- HTTP.get(%{client | connref: connref}, "/users/#{user_id}/groups") do

        user_details = Map.merge(found_user, %{"groups" => decoded_groups})
        user = merge_user_details(user, user_details)
        %{client | connref: connref, user: user}
    else
      {:error, reason} -> %{client | error: reason}
    end
  end

  def remove_groups(client = %{error: err}, _groups) when err != nil, do: client
  def remove_groups(client, :all) do
    all_groups = client.user.details
      |> Map.get("groups", [])
      |> Enum.map(fn(x) -> Map.fetch!(x, "id") end)

    Enum.reduce(all_groups, client, fn(group_id, acc) ->
      remove_group(acc, group_id)
    end)
  end
  def remove_groups(client, group_ids) do
    Enum.reduce(group_ids, client, fn(group_id, acc) ->
      remove_group(acc, group_id)
    end)
  end


  def remove_group(%Client{error: err} = client, _group) when err != nil, do: client
  def remove_group(%Client{user: %{details: %{"id" => user_id}}} = client, group_id) do
    case HTTP.delete(client, "/users/#{user_id}/groups/#{group_id}") do
      {:ok, connref, _decoded} -> %{client | connref: connref}
      {:error, reason} -> %{client | error: reason}
    end
  end
  def remove_group(client, _group_id) do
    %{client | error: "No \"id\" key found for user #{client.user.username}, please update user details with details/1"}
  end


  def join_group(%Client{error: err} = client, _group) when err != nil, do: client
  def join_group(%Client{user: %__MODULE__{details: %{"id" => user_id}}} = client, group_id) do
    case HTTP.put(client, "/users/#{user_id}/groups/#{group_id}", %{"id" => user_id, "groupId" => group_id}) do
      {:ok, connref, _decoded} -> %{client | connref: connref}
      {:error, reason} -> %{client | error: reason}
    end
  end
  def join_group(%Client{user: %__MODULE__{username: username}} = client, _group_id) do
    %{client | error: "No \"id\" key found for user #{username}, please update user details with details/1"}
  end
end
