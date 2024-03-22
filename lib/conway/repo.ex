defmodule Conway.Repo do
  use Ecto.Repo,
    otp_app: :conway,
    adapter: Ecto.Adapters.Postgres
end
