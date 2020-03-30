defmodule KeycloakAdmin.User do
  @enforce_keys [:username, :firstName, :lastName, :email]
  defstruct [
    :username,
    :firstName,
    :lastName,
    :email,
    attributes: %{},
    groups: [],
    enabled: true,
    credentials: []
  ]
end
