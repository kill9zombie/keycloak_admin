defmodule KeycloakAdmin.UserTest do
  @moduledoc false

  use ExUnit.Case

  import Mox

  setup :verify_on_exit!
  # test "greets the world" do
  #   assert KeycloakAdmin.hello() == :world
  # end
  test "creating a user" do
    KeycloakAdmin.HTTPMock
    |> expect(:request, fn :post,
                           _client,
                           "/users",
                           "{\"attributes\":{},\"credentials\":[],\"details\":{},\"email\":\"\",\"enabled\":true,\"firstName\":\"\",\"lastName\":\"\",\"username\":\"alice\"}",
                           _headers ->
      {:ok, :connref, ""}
    end)

    new_client =
      KeycloakAdmin.User.create_user(%KeycloakAdmin.Client{base_url: "test"}, %KeycloakAdmin.User{
        username: "alice"
      })

    assert new_client.user.username == "alice"
  end

  test "getting user details" do
    KeycloakAdmin.HTTPMock
    |> expect(:request, fn :get, _client, "/users?max=1&username=fred", _body, _headers ->
      {:ok, :connref, [%{"id" => "1", "firstName" => "Fred", "emailVerified" => false}]}
    end)
    |> expect(:request, fn :get, _client, "/users/1/groups", _body, _headers ->
      {:ok, :connref, [%{"id" => "g1"}, %{"id" => "g2"}]}
    end)

    client =
      KeycloakAdmin.User.details(%KeycloakAdmin.Client{base_url: "test"}, %KeycloakAdmin.User{
        username: "fred"
      })

    assert client.user ==
             %KeycloakAdmin.User{
               attributes: %{},
               credentials: '',
               details: %{
                 "emailVerified" => false,
                 "groups" => [%{"id" => "g1"}, %{"id" => "g2"}],
                 "firstName" => "Fred",
                 "id" => "1"
               },
               email: "",
               enabled: true,
               firstName: "Fred",
               lastName: "",
               username: "fred"
             }
  end

  # TODO - remove_groups
  #
  # TODO - join_group
end
