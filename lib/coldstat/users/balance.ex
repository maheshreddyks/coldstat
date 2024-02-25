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
  end
end
