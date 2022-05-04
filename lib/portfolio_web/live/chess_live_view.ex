defmodule PortfolioWeb.ChessLive do
  use PortfolioWeb, :live_view

  alias Portfolio.Chess
  alias Portfolio.ChessTiles

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, Chess.fill_board)
    {:ok, socket}
  end
end
