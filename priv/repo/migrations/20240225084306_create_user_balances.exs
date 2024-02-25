defmodule Coldstat.Repo.Migrations.CreateUserBalances do
  use Ecto.Migration

  def change do
    create table(:user_balances) do
      # add :user_id, references(:users, type: :uuid) -> if i have users table then we make references to this
      add :user_id, :uuid, primary_key: true
      add :amount, :integer

      timestamps()
    end

    create index(:user_balances, [:user_id])
  end
end
