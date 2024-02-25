defmodule Coldstat.Repo do
  use Ecto.Repo,
    otp_app: :coldstat,
    adapter: Ecto.Adapters.Postgres
end
