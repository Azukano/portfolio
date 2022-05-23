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
      chess_board_overlay: elem(Chess.spawn_pieces, 1))
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
    validate_coordinate_tile = if socket.assigns.sel_alpha < "a" or socket.assigns.sel_alpha > "h"
      or socket.assigns.sel_no < 1 or socket.assigns.sel_no > 8 do
      false
    else
      true
    end

    validate_color_tile = if validate_coordinate_tile == true do
      case socket
            |> Map.get(:assigns)
            |> Map.get(:chess_board_overlay)
            |> Map.get(atom_coordinate)
            |> Map.get(:color) do
        :black -> :black
        :white -> :white
        :red -> :red
        :"#8F00FF" -> :"#8F00FF"
        #_ -> nil
      end
    end

    if validate_color_tile == :red do
      move_piece = socket
      |> Map.get(:assigns)
      |> Map.get(:chess_pieces)
      |> Map.get(socket.assigns.target_piece_coordinate)
      |> Map.put(:coordinate_alpha, socket.assigns.sel_alpha)
      |> Map.put(:coordinate_no, socket.assigns.sel_no)

      updated_pieces_coordinate = socket
      |> Map.get(:assigns)
      |> Map.get(:chess_pieces)
      |> Map.delete(socket.assigns.target_piece_coordinate)
      |> Map.put(atom_coordinate, move_piece)

      move_occupant = socket
      |> Map.get(:assigns)
      |> Map.get(:chess_board)
      |> Map.get(atom_coordinate)
      |> Map.put(:occupant, socket.assigns.target_piece_occupant_id)

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

    atom_coordinate = String.to_atom(sel_alpha<>Integer.to_string(sel_no))

    target_piece_role = if Map.has_key?(socket.assigns.chess_pieces, atom_coordinate) do
      socket
      |> Map.get(:assigns)
      |> Map.get(:chess_pieces)
      |> Map.get(atom_coordinate)
      |> Map.get(:role)
    end

    validate_tile_occupancy = if target_piece_role != nil do
      true
    else
      false
    end

    case {validate_tile_occupancy, target_piece_role}  do
      { true, "pone" } ->
        pone_shaded = Chess.tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
        target_piece_occupant_id = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: pone_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        target_piece_coordinate: atom_coordinate,
        target_piece_role: target_piece_role,
        target_piece_occupant_id: target_piece_occupant_id )

        {:noreply, socket}
      { true, "rook" } ->
        rook_shaded = Chess.tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
        target_piece_occupant_id = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: rook_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        target_piece_coordinate: atom_coordinate,
        target_piece_role: target_piece_role,
        target_piece_occupant_id: target_piece_occupant_id )

        {:noreply, socket}
      { true, "knight" } ->
        knight_shaded = Chess.tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role)
        target_piece_occupant_id = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: knight_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        target_piece_coordinate: atom_coordinate,
        target_piece_role: target_piece_role,
        target_piece_occupant_id: target_piece_occupant_id )

        {:noreply, socket}
      { true, "bishop" } ->
        bishop_shaded = Chess.tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
        target_piece_occupant_id = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: bishop_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        target_piece_coordinate: atom_coordinate,
        target_piece_role: target_piece_role,
        target_piece_occupant_id: target_piece_occupant_id )

        {:noreply, socket}
      { true, "queen" } ->
        queen_shaded = Chess.tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
        target_piece_occupant_id = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: queen_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        target_piece_coordinate: atom_coordinate,
        target_piece_role: "queen", #important to reclaim queen roll after undergoing bishop red shade
        target_piece_occupant_id: target_piece_occupant_id )

        {:noreply, socket}
      { true, "king" } ->
        king_shaded = Chess.tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
        target_piece_occupant_id = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: king_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        target_piece_coordinate: atom_coordinate,
        target_piece_role: target_piece_role,
        target_piece_occupant_id: target_piece_occupant_id )

        {:noreply, socket}
      { false, _ } ->
        IO.puts "nil tile/invalid coordinate"
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

end
