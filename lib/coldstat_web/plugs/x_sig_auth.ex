defmodule ColdstatWeb.Plugs.XSigAuth do
  import Plug.Conn
  @behaviour Plug

  def init(options), do: options

  def call(conn, _params) do
    case get_req_header(conn, "x-hub88-signature") |> Enum.at(0) do
      nil ->
        send_unauthorized(conn)

      signature ->
        payload = conn.params |> Jason.encode!()

        if Coldstat.Communications.Helper.validate_signature?(payload, signature) do
          conn
        else
          send_unauthorized(conn)
        end
    end
  end

  defp send_unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> send_resp(401, Jason.encode!(%{error: "Unauthorized"}))
    |> halt()
  end
end
