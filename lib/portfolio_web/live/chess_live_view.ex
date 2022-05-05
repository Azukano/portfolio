defmodule PortfolioWeb.ChessLive do
  require Integer
  use PortfolioWeb, :live_view

  alias Portfolio.Chess

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, chess_board: Chess.fill_board)
    {:ok, socket}
  end
end
