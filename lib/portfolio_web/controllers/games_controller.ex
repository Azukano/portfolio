defmodule PortfolioWeb.GamesController do
  use PortfolioWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _) do
    live_render(conn, PortfolioWeb.GamesLive, session: %{
      "current_user_id" => get_session(conn, :user_id)
    })
  end

end
