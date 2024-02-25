defmodule ColdstatWeb.Plugs.Idempotency do
  import Plug.Conn
  @behaviour Plug

  def init(options), do: options

  def call(conn, _params) do
    # NOTE: There is an advanced version of handling this.
    # Where in we can specifically add in controller for required functions
    # Due to time constraint I couldnt add this here.
    case conn.params["transaction_uuid"] do
      nil ->
        conn

      transaction_uuid ->
        case Hammer.check_rate(transaction_uuid, 1000 * 3600, 1) do
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
