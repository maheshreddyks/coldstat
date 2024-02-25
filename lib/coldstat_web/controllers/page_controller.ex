defmodule ColdstatWeb.PageController do
  use ColdstatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
