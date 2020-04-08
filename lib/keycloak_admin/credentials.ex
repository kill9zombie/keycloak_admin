defmodule KeycloakAdmin.Credentials do

  @type t :: %__MODULE__{type: String.t(), temporary: Boolean, value: String.t()}

  @derive {Jason.Encoder, only: [:value, :type, :temporary]}

  @enforce_keys [:value]
  defstruct [value: "", type: "password", temporary: true]
end
