defmodule KeycloakAdmin.HTTPClient do
  @moduledoc false

  # Only used during testing so that Mox can mock this behaviour.

  @type method :: :get | :post | :delete
  @type uri :: String.t()
  @type client :: KeycloakAdmin.Client.t()
  @type request_body :: String.t() | tuple() | map()
  @type extra_headers :: map()

  @type response :: {:ok, term(), map() | list()}

  @callback request(method, client, uri, request_body, extra_headers) :: response | {:error, any()}
end
