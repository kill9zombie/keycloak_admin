defmodule KeycloakAdmin.HTTP do
  @moduledoc ~S"""
  A mock-able HTTP client adaptor for KeycloakAdmin
  """

  @http_client Application.get_env(:keycloak_admin, :http_client, KeycloakAdmin.HTTP)

  require Logger

  @behaviour KeycloakAdmin.HTTPClient

  defp json_decode(""), do: {:ok, %{}}
  defp json_decode(body), do: Jason.decode(body)

  def post(client, url, request_body, extra_headers \\ %{})
  def post(client, url, request_body, extra_headers) when is_map(request_body) do
    case Jason.encode(request_body) do
      {:ok, encoded} -> post(client, url, encoded, Map.merge(extra_headers, %{"Content-Type" => "application/json"}))
      {:error, _} = err -> err
    end
  end
  def post(client, url, request_body, extra_headers) do
    request_headers = List.flatten(Map.to_list(client.default_headers), Map.to_list(extra_headers))
    @http_client.request(:post, client, url, request_body, request_headers)
  end

  def put(client, url, request_body, extra_headers \\ %{})
  def put(client, url, request_body, extra_headers) when is_map(request_body) do
    case Jason.encode(request_body) do
      {:ok, encoded} -> put(client, url, encoded, Map.merge(extra_headers, %{"Content-Type" => "application/json"}))
      {:error, _} = err -> err
    end
  end
  def put(client, url, request_body, extra_headers) do
    request_headers = List.flatten(Map.to_list(client.default_headers), Map.to_list(extra_headers))
    @http_client.request(:put, client, url, request_body, request_headers)
  end

  def get(client, url, extra_headers \\ %{}) do
    request_headers = List.flatten(Map.to_list(client.default_headers), Map.to_list(extra_headers))
    @http_client.request(:get, client, url, "", request_headers)
  end

  def delete(client, url, extra_headers \\ %{}) do
    request_headers = List.flatten(Map.to_list(client.default_headers), Map.to_list(extra_headers))
    @http_client.request(:delete, client, url, "", request_headers)
  end

  @impl true
  def request(method, client, url, body, headers) do
    with {:ok, code, _resp_headers, connref} when code in 200..299 <-
           :hackney.request(
              method,
             "#{client.base_url}#{url}",
             headers,
             body,
             client.options
           ),
         {:ok, body} <- :hackney.body(connref),
         {:ok, decoded} <- json_decode(body) do
      {:ok, connref, decoded}
    else
      {:ok, 401, _resp_headers, _connref} -> {:error, [:unauthorized, "HTTP Unauthorized while requesting #{url}, please check your access token"]}
      {:ok, 409, _resp_headers, connref} -> {:error, [:duplicate, "#{get_body(connref) |> Map.get("errorMessage", "Unknown duplicate error")}"]}
      {:ok, code, _resp_headers, connref} when code in 500..599 -> {:error, [:server_error, "HTTP server error: #{inspect get_body(connref)}"]}
      {:ok, code, _resp_headers, connref} -> {:error, [:unknown, "Unexpected HTTP response code #{code}: #{inspect get_body(connref)}"]}
    end
  end

  defp get_body(connref) do
    with {:ok, json_body} <- :hackney.body(connref),
         {:ok, json} <- json_decode(json_body) do
         json
    else
      {:error, reason} ->
        Logger.warn fn -> "couldn't decode hackney body: #{inspect reason}" end
        ""
    end
  end

end
