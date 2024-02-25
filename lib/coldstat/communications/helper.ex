defmodule Coldstat.Communications.Helper do
  @moduledoc """
    This module helps us build the secured payload with signed headers
  """
  @digest_type :sha256

  @spec make_request(Map.t()) ::
          {:ok,
           HTTPoison.Response.t()
           | HTTPoison.AsyncResponse.t()
           | HTTPoison.MaybeRedirect.t()}
          | {:error, HTTPoison.Error.t()}
  def make_request(params) do
    headers = generate_headers(params.payload)

    HTTPoison.request(params.method, params.endpoint, params.payload, headers)
  end

  @spec generate_headers(String.t()) :: [Tuple.t()]
  defp generate_headers(payload) do
    [
      {"X-Hub88-Signature", generate_signature(payload)}
    ]
  end

  @spec generate_signature(String.t()) :: String.t()
  def generate_signature(payload) do
    path = Application.app_dir(:coldstat, "priv/files")

    private_key = File.read!("#{path}/private_key.pem")

    HmCrypto.sign!(payload, @digest_type, private_key)
  end

  @spec validate_signature?(String.t(), String.t()) :: boolean()
  def validate_signature?(payload, signature) do
    path = Application.app_dir(:coldstat, "priv/files")

    public_key = File.read!("#{path}/public_key.pem")

    HmCrypto.valid?(payload, signature, @digest_type, public_key)
  end
end
