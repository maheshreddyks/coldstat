defmodule ColdstatWeb.Plugs.Idempotency do
  import Plug.Conn
  @behaviour Plug

  def init(options), do: options

  def call(conn, _params) do
    case conn.params["transaction_uuid"] do
      nil ->
        conn

      transaction_uuid ->
        case Hammer.check_rate(transaction_uuid, 1000 * 60000, 1) do
          {:allow, _} ->
            conn

          _ ->
            send_idempotent(conn)
        end
    end
  end

  defp send_idempotent(conn) do
    conn
    |> put_status(:unauthorized)
    |> send_resp(409, Jason.encode!(%{error: "Idempotent Request"}))
    |> halt()
  end
end
