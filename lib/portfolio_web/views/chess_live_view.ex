defmodule PortfolioWeb.ChessLive do
  require Integer
  use PortfolioWeb, :live_view

  alias Portfolio.Chess

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, chess_board: Chess.fill_board, key_press: "none", sel_alpha: "a", sel_alpha_pointer: 1, sel_no: 1)
    {:ok, socket}
  end

  @impl true
  def handle_event("tile_selection", %{"key" => key_up}, socket)
    when key_up != "ArrowUp" and "ArrowDown" and "ArrowLeft" and "ArrowRight" do
    IO.puts "guard clause for tile_selection"
    {:noreply, socket}
  end

  def handle_event("tile_selection", %{"key" => key_up}, socket) do
    sel_no = case key_up do
      "ArrowUp" ->
        if socket.assigns.sel_no < 9 do
          socket.assigns.sel_no + 1
        else
          IO.puts "reached the edge of chess board"
          put_flash(socket, :error, "You can't access that page")
          socket.assigns.sel_no
        end
      "ArrowDown" ->
        if socket.assigns.sel_no > 0 do
          socket.assigns.sel_no - 1
        else
          IO.puts "reached the edge of chess board"
          socket.assigns.sel_no
        end
      _ ->
        socket.assigns.sel_no
    end
    sel_alpha_pointer = case key_up do
      "ArrowRight" ->
        if socket.assigns.sel_alpha_pointer < 9 do
          socket.assigns.sel_alpha_pointer + 1
        else
          IO.puts "reached the edge of chess board"
          socket.assigns.sel_alpha_pointer
        end
      "ArrowLeft" ->
        if socket.assigns.sel_alpha_pointer > 0 do
          socket.assigns.sel_alpha_pointer - 1
        else
          IO.puts "reached the edge of chess board"
          socket.assigns.sel_alpha_pointer
        end
      _ ->
        socket.assigns.sel_alpha_pointer
    end
    socket = assign(socket, sel_no: sel_no, sel_alpha: <<96+sel_alpha_pointer>>, sel_alpha_pointer: sel_alpha_pointer)
    {:noreply, socket}
  end

  def handle_event("col_right_left", %{"key" => key_up}, socket) do
    IO.puts "pumasok sa col left right"
  end


  def handle_event("down_row", %{"key" => "ArrowDown"}, socket) do
    IO.puts("pumasok sa up_arrow")
    sel_no = socket.assigns.sel_no
    socket = assign(socket, sel_no: sel_no - 1)
    {:noreply, socket}
  end

  def handle_event("key_press", %{"key" => key}, socket) do
    #socket = assign(socket, Map.replace(socket.assigns.chess_board.a1, :color, :RED))
    #IO.inspect socket.assigns.chess_board.a1
    IO.inspect key
    socket = assign(socket, key_press: key, )
    {:noreply, socket}
  end

end
