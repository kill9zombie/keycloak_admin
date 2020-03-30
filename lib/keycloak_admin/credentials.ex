defmodule KeycloakAdmin.KeycloakCredentials do

  @type t :: %__MODULE__{type: String.t(), temporary: Boolean, value: String.t}

  @enforce_keys [:value]
  defstruct [:value, type: "password", temporary: true]
end
