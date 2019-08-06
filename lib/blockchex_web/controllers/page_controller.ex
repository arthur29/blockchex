defmodule BlockchexWeb.PageController do
  use BlockchexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
