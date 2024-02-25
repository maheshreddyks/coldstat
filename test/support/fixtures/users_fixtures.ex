defmodule Coldstat.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Coldstat.Users` context.
  """

  @doc """
  Generate a balance.
  """
  def balance_fixture(attrs \\ %{}) do
    {:ok, balance} =
      attrs
      |> Enum.into(%{
        amount: 42,
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Coldstat.Users.create_balance()

    balance
  end
end
