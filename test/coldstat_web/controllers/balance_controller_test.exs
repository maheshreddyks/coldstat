defmodule ColdstatWeb.BalanceControllerTest do
  use ColdstatWeb.ConnCase

  import Coldstat.UsersFixtures

  # alias Coldstat.Users.Balance
  # alias Coldstat.Users
  alias Coldstat.Communications.Helper

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "renders balance" do
    setup [:create_balance]

    test "renders balance when data is valid", %{conn: conn, balance: balance} do
      conn = get(conn, Routes.balance_path(conn, :show, balance.user_id))
      result_data = json_response(conn, 200)["data"]

      assert balance.amount == result_data["amount"]
      assert balance.user_id == result_data["user_id"]
    end

    test "renders data nil when data is invalid", %{conn: conn} do
      conn = get(conn, Routes.balance_path(conn, :show, UUID.uuid4()))
      assert json_response(conn, 200)["data"] == nil
    end
  end

  describe "credit balance" do
    setup [:create_balance]

    test "renders balance when data is valid", %{
      conn: conn,
      balance: balance
    } do
      payload = %{
        user_id: balance.user_id,
        transaction_uuid: UUID.uuid4(),
        amount: "25"
      }

      signature =
        payload
        |> Jason.encode!()
        |> Helper.generate_signature()

      conn = put_req_header(conn, "x-hub88-signature", signature)
      conn = post(conn, Routes.balance_path(conn, :credit_transaction, payload))
      result_data = json_response(conn, 200)["data"]
      assert 67 == result_data["amount"]
      assert "7488a646-e31f-11e4-aace-600308960662" == result_data["user_id"]
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance} do
      payload = %{
        user_id: balance.user_id,
        transaction_uuid: UUID.uuid4(),
        amount: "25"
      }

      invalid_payload = %{payload | amount: "here"}

      conn = post(conn, Routes.balance_path(conn, :credit_transaction, invalid_payload))

      assert json_response(conn, 422)["error"] == "issue_with_amount"
    end
  end

  describe "debit balance" do
    setup [:create_balance]

    test "renders balance when data is valid", %{
      conn: conn,
      balance: balance
    } do
      payload = %{
        user_id: balance.user_id,
        transaction_uuid: UUID.uuid4(),
        amount: "25"
      }

      signature =
        payload
        |> Jason.encode!()
        |> Helper.generate_signature()

      conn = put_req_header(conn, "x-hub88-signature", signature)
      conn = post(conn, Routes.balance_path(conn, :debit_transaction, payload))
      result_data = json_response(conn, 200)["data"]
      assert 17 == result_data["amount"]
      assert "7488a646-e31f-11e4-aace-600308960662" == result_data["user_id"]
    end

    test "renders balance when amount is greater than the balance", %{
      conn: conn,
      balance: balance
    } do
      payload = %{
        user_id: balance.user_id,
        transaction_uuid: UUID.uuid4(),
        amount: "125"
      }

      signature =
        payload
        |> Jason.encode!()
        |> Helper.generate_signature()

      conn = put_req_header(conn, "x-hub88-signature", signature)
      conn = post(conn, Routes.balance_path(conn, :debit_transaction, payload))

      assert %{"amount" => ["Balance Insufficient"]} = json_response(conn, 422)["errors"]
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance} do
      payload = %{
        user_id: balance.user_id,
        transaction_uuid: UUID.uuid4(),
        amount: "25"
      }

      invalid_payload = %{payload | amount: "here"}

      conn = post(conn, Routes.balance_path(conn, :debit_transaction, invalid_payload))

      assert json_response(conn, 422)["error"] == "issue_with_amount"
    end
  end

  describe "idempotency test" do
    setup [:create_balance]

    test "renders balance when data is valid", %{
      conn: conn,
      balance: balance
    } do
      payload = %{
        user_id: balance.user_id,
        transaction_uuid: UUID.uuid4(),
        amount: "25"
      }

      signature =
        payload
        |> Jason.encode!()
        |> Helper.generate_signature()

      req_conn = put_req_header(conn, "x-hub88-signature", signature)
      conn = post(req_conn, Routes.balance_path(req_conn, :debit_transaction, payload))
      result_data = json_response(conn, 200)["data"]
      assert 17 == result_data["amount"]
      assert "7488a646-e31f-11e4-aace-600308960662" == result_data["user_id"]
      ## Trying to insert the same data again
      conn = post(req_conn, Routes.balance_path(req_conn, :debit_transaction, payload))
      assert conn.status == 409
      assert Jason.decode!(conn.resp_body)["error"] == "Idempotent Request"
    end
  end

  defp create_balance(_) do
    balance = balance_fixture()
    %{balance: balance}
  end
end
