defmodule KeycloakAdmin.ClientTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  test "creating a client with a username and password" do
    KeycloakAdmin.HTTPMock
    |> expect(:request, fn(:post, %KeycloakAdmin.Client{base_url: _}, "/protocol/openid-connect/token", _body, _headers) ->
         {:ok, :connref, %{"access_token" => 1}}
       end)

    %KeycloakAdmin.Client{access_token: access_token} = KeycloakAdmin.Client.build_client("http://mock.localnet", "testrealm", "username", "password")

    assert access_token == 1
  end

end
