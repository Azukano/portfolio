defmodule PortfolioWeb.ChessController do
  use PortfolioWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _) do
    live_render(conn, PortfolioWeb.ChessLive, session: %{
      "current_user_id" => get_session(conn, :user_id)
    })
  end

end
