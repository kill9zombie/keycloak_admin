defmodule KeycloakAdmin.Client do

  @type t :: Tesla.Client.t()

  def build_client(base_url, realm, access_token) do
    client_options = Application.get_env(:keycloak_admin, :client_options, [])

    middleware = [
      {Tesla.Middleware.BaseUrl, "#{base_url}/auth/realms/#{realm}"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]},
      {Tesla.Middleware.Opts, client_options}
    ]

    Tesla.client(middleware)
  end
end
