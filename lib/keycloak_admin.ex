defmodule KeycloakAdmin do
  @moduledoc """
  Documentation for `KeycloakAdmin`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> KeycloakAdmin.hello()
      :world

  """
  def hello do
    :world
  end

  def client(base_url, keycloak_realm, access_token) do
    KeycloakAdmin.Client.build_client(base_url, keycloak_realm, access_token)
  end

  def get_groups(client) do
    case Client.request(client, method: :get, url: "/groups") do
      {:ok, %Tesla.Env{status: 200, body: body}} -> KeycloakAdmin.Groups.from_maps(body)
      {:ok, %Tesla.Env{body: body}} -> {:error, body}
      {:error, _} = err -> err
    end
  end
end
