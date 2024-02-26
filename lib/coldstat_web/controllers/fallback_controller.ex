defmodule ColdstatWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ColdstatWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:ok, {:error, %Ecto.Changeset{} = changeset}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ColdstatWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ColdstatWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, [error_message]}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ColdstatWeb.ErrorView)
    |> json(%{error: error_message})
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, error_message}) when is_binary(error_message) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ColdstatWeb.ErrorView)
    |> json(%{error: error_message})
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, error_message}) when is_atom(error_message) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ColdstatWeb.ErrorView)
    |> json(%{error: "#{error_message}"})
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ColdstatWeb.ErrorView)
    |> render(:"404")
  end
end
