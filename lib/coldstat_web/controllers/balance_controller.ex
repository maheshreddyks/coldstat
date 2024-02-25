defmodule ColdstatWeb.BalanceController do
  use ColdstatWeb, :controller

  alias Coldstat.Users
  alias Coldstat.Users.Balance
  alias Skooma.Validators

  action_fallback ColdstatWeb.FallbackController

  def show(conn, %{"user_id" => user_id}) do
    balance = Users.get_balance!(user_id)
    render(conn, "show.json", balance: balance)
  end

  def credit_transaction(conn, params) do
    with :ok <- Skooma.valid?(params, valid_schema()),
         {:ok, %Balance{} = balance} <- Users.execute_transaction(params, :credit) do
      render(conn, "show.json", balance: balance)
    end
  end

  def debit_transaction(conn, params) do
    with :ok <- Skooma.valid?(params, valid_schema()),
         {:ok, %Balance{} = balance} <- Users.execute_transaction(params, :debit) do
      render(conn, "show.json", balance: balance)
    end
  end

  defp valid_schema() do
    %{
      "transaction_uuid" => [:string, Validators.min_length(36), Validators.max_length(36)],
      "amount" => :string,
      "user_id" => [:string, Validators.min_length(36), Validators.max_length(36)]
    }
  end
end
