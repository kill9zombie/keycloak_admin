defmodule KeycloakAdmin.Client do
  @moduledoc ~S"""
  Replesents a client.

  client = KeycloakAdmin.Client.build_client("https://keycloak.localnet", "master", "AccessTokenABCD")


  """
  defstruct [:base_url, :access_token, :options, :error, :connref, default_headers: %{}, user: %{}, groups: []]

  @http KeycloakAdmin.HTTP

  def build_client(base_url, realm, username, password) do
    options = Application.get_env(:keycloak_admin, :client_options, [])

    token_client = %__MODULE__{
      base_url: "#{String.trim(base_url, "/")}/auth/realms/#{realm}",
      options: options
    }

    case get_access_token(token_client, :admin_cli, username, password) do
      {:ok, _client, token} -> build_client(base_url, realm, token)
      {:error, _} = err -> %{token_client | error: err}
    end
  end

  def build_client(base_url, realm, access_token) do
    options = Application.get_env(:keycloak_admin, :client_options, [])

    %__MODULE__{
      base_url: "#{String.trim(base_url, "/")}/auth/admin/realms/#{realm}",
      options: options,
      access_token: access_token,
      default_headers: %{"Authorization" => "Bearer #{access_token}"}
    }
  end

  def get_access_token(client, :admin_cli, username, password) do
    request_form =
      {:form,
       [
         client_id: "admin-cli",
         grant_type: "password",
         username: username,
         password: password
       ]}

    case @http.post(client, "/protocol/openid-connect/token", request_form) do
      {:ok, connref, decoded} ->
        {:ok, %{client | connref: connref}, decoded["access_token"]}

      {:error, _} = err ->
        err
    end
  end

end
