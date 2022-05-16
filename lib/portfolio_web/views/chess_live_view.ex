defmodule PortfolioWeb.ChessLive do
  require Integer
  use PortfolioWeb, :live_view

  alias Portfolio.Chess

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket,
      chess_board: elem(Chess.spawn_pieces, 1),
      key_press: "none", sel_alpha: "a",
      sel_alpha_pointer: 1, sel_no: 1,
      chess_pieces: elem(Chess.spawn_pieces, 0),
      selection_toggle: false,
      chess_board_overlay: Chess.fill_board(true))
    {:ok, socket}
  end

  @impl true
  def handle_event("tile_selection", %{"key" => key_up}, socket)
    when key_up not in ["Enter", "ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"] do
    IO.puts "guard clause for tile_selection"
    {:noreply, socket}
  end

  # second keyup enter press
  def handle_event("tile_selection", %{"key" => key_up}, socket)
    when key_up == "Enter" and socket.assigns.selection_toggle == true do

    atom_coordinate = String.to_atom(socket.assigns.sel_alpha<>Integer.to_string(socket.assigns.sel_no))
    if socket
      |> Map.get(:assigns)
      |> Map.get(:chess_board_overlay)
      |> Map.get(atom_coordinate)
      |> Map.get(:color) == :red do

      move_piece = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_pieces)
        |> Map.get(socket.assigns.target_piece_coordinate)
        |> Map.put(:coordinate_alpha, socket.assigns.sel_alpha)
        |> Map.put(:coordinate_no, socket.assigns.sel_no)

      updated_pieces_coordinate = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_pieces)
        |> Map.put(atom_coordinate, move_piece)

      move_occupant = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.put(:occupant, "p1")

      remove_target_occupant = socket
      |> Map.get(:assigns)
      |> Map.get(:chess_board)
      |> Map.get(socket.assigns.target_piece_coordinate)
      |> Map.put(:occupant, nil)

      updated_tiles_occupant = socket
      |> Map.get(:assigns)
      |> Map.get(:chess_board)
      |> Map.put(atom_coordinate, move_occupant)
      |> Map.put(socket.assigns.target_piece_coordinate, remove_target_occupant)



      # IO.inspect socket
      #   |> Map.get(:assigns)
      #   |> Map.get(:chess_board)

      # chess_board = socket
      # |> Map.get(:assigns)
      # |> Map.get(:chess_board)

      #update_board()

      socket = assign(socket, selection_toggle: false, chess_pieces: updated_pieces_coordinate, chess_board_overlay: socket.assigns.old_chess_board_overlay, chess_board: updated_tiles_occupant)
        {:noreply, socket}
    else
      socket = assign(socket, selection_toggle: false, chess_board: socket.assigns.old_chess_board, chess_board_overlay: socket.assigns.old_chess_board_overlay)
      {:noreply, socket}
    end
  end

  # first keyup enter press
  def handle_event("tile_selection", %{"key" => key_up}, socket)
    when key_up == "Enter" and socket.assigns.selection_toggle == false do

    old_chess_board = socket.assigns.chess_board
    old_chess_board_overlay = socket.assigns.chess_board_overlay

    sel_alpha = socket.assigns.sel_alpha
    sel_no = socket.assigns.sel_no

    atom_coordinate = String.to_atom(socket.assigns.sel_alpha<>Integer.to_string(socket.assigns.sel_no))

    if atom_coordinate in Map.keys(socket.assigns.chess_pieces) and socket
    |> Map.get(:assigns)
    |> Map.get(:chess_pieces)
    |> Map.get(atom_coordinate)
    |> Map.get(:role) == "pone"  do
      pone_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1)
      socket = assign(socket, selection_toggle: :true, chess_board_overlay: pone_shaded, old_chess_board_overlay: old_chess_board_overlay, old_chess_board: old_chess_board, target_piece_coordinate: atom_coordinate)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("tile_selection", %{"key" => key_up}, socket) do
    sel_no = case key_up do
      "ArrowUp" ->
        if socket.assigns.sel_no < 9 do
          socket.assigns.sel_no + 1
        else
          IO.puts "reached the edge of chess board"
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

  def handle_event("key_press", %{"key" => key}, socket) do
    IO.inspect key
    socket = assign(socket, key_press: key, )
    {:noreply, socket}
  end

  #PONE TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, i) when i > 2 do
    chess_board
  end

  #PONE TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, i) do
    coordinate_atom = String.to_atom(sel_alpha<>Integer.to_string(sel_no + i))
    pone_step_1 = chess_board
    |> Map.get(coordinate_atom)
    |> Map.put(:color, :red)

    new_chess_board_with_red_tile = chess_board
    |> Map.put(coordinate_atom, pone_step_1)
    pone_step_1
    tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1)
  end

end

#for {key, value} <- chess_pieces, value.coordinate_alpha == coordinate_alpha and value.coordinate_no == coordinate_no do
#  IO.puts("#{key}: #{value.coordinate_alpha} #{value.coordinate_no}")
#  piece = Chess.piece_movement(socket.assigns.chess_pieces, piece_id, coordinate_alpha, coordinate_no)
#  socket = assign(socket, chess_pieces: piece)
#  IO.inspect socket.assigns.chess_pieces, label: "after assign inside"
#end

# new_p1_coordinate_no = socket |> Map.get(:assigns) |> Map.get(:chess_pieces) |> Map.get(:p1) |> Map.put(:coordinate_no, )
# new_chess_p1 = socket |> Map.get(:assigns) |> Map.get(:chess_pieces) |> Map.put(:p1, new_p1_coordinate_no)
