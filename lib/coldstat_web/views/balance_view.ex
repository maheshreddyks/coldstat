defmodule ColdstatWeb.BalanceView do
  use ColdstatWeb, :view
  alias ColdstatWeb.BalanceView

  def render("index.json", %{user_balances: user_balances}) do
    %{data: render_many(user_balances, BalanceView, "balance.json")}
  end

  def render("show.json", %{balance: {:ok, balance}}) do
    %{data: render_one(balance, BalanceView, "balance.json")}
  end

  def render("show.json", %{balance: balance}) do
    %{data: render_one(balance, BalanceView, "balance.json")}
  end

  def render("show.json", {:ok, %{balance: balance}}) do
    %{data: render_one(balance, BalanceView, "balance.json")}
  end

  def render("balance.json", %{balance: balance}) do
    %{
      id: balance.id,
      user_id: balance.user_id,
      amount: balance.amount
    }
  end
end
