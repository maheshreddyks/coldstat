defmodule Coldstat.Users.Balance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_balances" do
    field :amount, :integer
    field :user_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(balance, attrs) do
    balance
    |> cast(attrs, [:user_id, :amount])
    |> validate_required([:user_id, :amount])
    |> unique_constraint(:user_id, message: "This user_id is already recorded")
    |> validate_number(:amount, greater_than_or_equal_to: 0, message: "Balance Insufficient")
  end
end
