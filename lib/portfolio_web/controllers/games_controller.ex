defmodule PortfolioWeb.GamesController do
  use PortfolioWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
