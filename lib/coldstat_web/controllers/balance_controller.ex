defmodule ColdstatWeb.BalanceController do
  use ColdstatWeb, :controller

  alias Coldstat.Users
  alias Coldstat.Users.Balance

  action_fallback ColdstatWeb.FallbackController

  def index(conn, _params) do
    user_balances = Users.list_user_balances()
    render(conn, "index.json", user_balances: user_balances)
  end

  def create(conn, %{"balance" => balance_params}) do
    with {:ok, %Balance{} = balance} <- Users.create_balance(balance_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.balance_path(conn, :show, balance))
      |> render("show.json", balance: balance)
    end
  end

  def show(conn, %{"id" => id}) do
    balance = Users.get_balance!(id)
    render(conn, "show.json", balance: balance)
  end

  def update(conn, %{"id" => id, "balance" => balance_params}) do
    balance = Users.get_balance!(id)

    with {:ok, %Balance{} = balance} <- Users.update_balance(balance, balance_params) do
      render(conn, "show.json", balance: balance)
    end
  end

  def delete(conn, %{"id" => id}) do
    balance = Users.get_balance!(id)

    with {:ok, %Balance{}} <- Users.delete_balance(balance) do
      send_resp(conn, :no_content, "")
    end
  end
end
