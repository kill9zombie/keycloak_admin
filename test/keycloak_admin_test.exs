defmodule KeycloakAdminTest do
  use ExUnit.Case
  doctest KeycloakAdmin

  import Mox

  setup :verify_on_exit!
  # test "greets the world" do
  #   assert KeycloakAdmin.hello() == :world
  # end
  test "resolving errors" do
    client = %KeycloakAdmin.Client{error: "some big error"}

    assert KeycloakAdmin.resolve_errors(client) == {:error, "some big error"}
  end
end
