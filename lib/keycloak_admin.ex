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

  def client(base_url, keycloak_realm, username, password) do
    KeycloakAdmin.Client.build_client(base_url, keycloak_realm, username, password)
  end

  def client(base_url, keycloak_realm, access_token) do
    KeycloakAdmin.Client.build_client(base_url, keycloak_realm, access_token)
  end

  def resolve_errors(%KeycloakAdmin.Client{error: nil}), do: :ok
  def resolve_errors(%KeycloakAdmin.Client{error: reason}), do: {:error, reason}
    
end
