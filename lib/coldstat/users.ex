defmodule Coldstat.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Coldstat.Repo

  alias Coldstat.Users.Balance

  @doc """
  Gets a single balance.

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance!(123)
      %Balance{}

      iex> get_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance!(id), do: Repo.get_by(Balance, user_id: id)

  @doc """
  Creates a balance.

  ## Examples

      iex> create_balance(%{field: value})
      {:ok, %Balance{}}

      iex> create_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_balance(attrs \\ %{}) do
    %Balance{}
    |> Balance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a balance.

  ## Examples

      iex> update_balance(balance, %{field: new_value})
      {:ok, %Balance{}}

      iex> update_balance(balance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_balance(%Balance{} = balance, attrs) do
    balance
    |> Balance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking balance changes.

  ## Examples

      iex> execute_transaction(attrs,type)
      {:ok, %Balance{}}

      iex> execute_transaction(attrs,type)
      {:error, %Ecto.Changeset{}}

      iex> execute_transaction(attrs,type)
      {:error, :reason}

  """
  def execute_transaction(attrs, type) do
    if balance = get_balance!(attrs["user_id"]) do
      case to_integer(attrs["amount"]) do
        nil ->
          {:error, :issue_with_amount}

        amount ->
          update_attrs =
            if type == :credit,
              do: %{amount: balance.amount + amount},
              else: %{amount: balance.amount - amount}

          update_balance(balance, update_attrs)
      end
    else
      {:error, :no_user_found}
    end
  end

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {i, _} ->
        i

      _default ->
        nil
    end
  end

  defp to_integer(value) when is_integer(value), do: value

  # sometimes we will get nil value from supplier response
  defp to_integer(value) when is_nil(value), do: nil

  defp to_integer(_value), do: nil
end
