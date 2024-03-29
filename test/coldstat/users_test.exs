defmodule Coldstat.UsersTest do
  use Coldstat.DataCase

  alias Coldstat.Users

  describe "user_balances" do
    alias Coldstat.Users.Balance

    import Coldstat.UsersFixtures

    @invalid_attrs %{amount: nil, user_id: nil}

    test "get_balance!/1 returns the balance with given id" do
      balance = balance_fixture()
      assert Users.get_balance!(balance.user_id) == balance
    end

    test "create_balance/1 with valid data creates a balance" do
      valid_attrs = %{amount: 42, user_id: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Balance{} = balance} = Users.create_balance(valid_attrs)
      assert balance.amount == 42
      assert balance.user_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_balance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_balance(@invalid_attrs)
    end

    test "update_balance/2 with valid data updates the balance" do
      balance = balance_fixture()
      update_attrs = %{amount: 43, user_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Balance{} = balance} = Users.update_balance(balance, update_attrs)
      assert balance.amount == 43
      assert balance.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_balance/2 with invalid data returns error changeset" do
      balance = balance_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_balance(balance, @invalid_attrs)
      assert balance == Users.get_balance!(balance.user_id)
    end
  end
end
