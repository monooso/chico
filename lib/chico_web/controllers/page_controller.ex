defmodule ChicoWeb.PageController do
  use ChicoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
