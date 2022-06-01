defmodule PortfolioWeb.ChessLive do
  require Integer
  use PortfolioWeb, :live_view

  alias Portfolio.Chess

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket,
      chess_board: elem(Chess.spawn_pieces, 2),
      key_press: "none", sel_alpha: "a",
      sel_alpha_pointer: 1, sel_no: 1,
      chess_pieces_white: elem(Chess.spawn_pieces, 0),
      chess_pieces_black: elem(Chess.spawn_pieces, 1),
      selection_toggle: false,
      chess_board_overlay: elem(Chess.spawn_pieces, 2),
      past_pone_tuple_combo: { nil, nil, false, nil },
      presume_tiles_white: Chess.presume_tiles(elem(Chess.spawn_pieces, 0), elem(Chess.spawn_pieces, 1), :chess_pieces_white, elem(Chess.spawn_pieces, 2)) |> elem(0),
      presume_tiles_black: Chess.presume_tiles(elem(Chess.spawn_pieces, 1), elem(Chess.spawn_pieces, 0), :chess_pieces_black, elem(Chess.spawn_pieces, 2)) |> elem(0),
      check_condition_white: false,
      check_condition_black: false,
      black_king_mate: nil,
      white_king_mate: nil)
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

    sel_no = socket.assigns.sel_no
    atom_coordinate = String.to_atom(socket.assigns.sel_alpha<>Integer.to_string(sel_no))
    attacker_piece_coordinate = socket.assigns.attacker_piece_coordinate
    attacker_piece_coordinate_no = socket.assigns.attacker_piece_coordinate_no
    attacker_piece_coordinate_alpha = socket.assigns.attacker_piece_coordinate_alpha

    validate_coordinate_tile = if socket.assigns.sel_alpha < "a" or socket.assigns.sel_alpha > "h"
      or sel_no < 1 or sel_no > 8 do
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

    chess_piece_side = socket.assigns.attacker_piece_side
    chess_piece_opponent = if chess_piece_side == :chess_pieces_white do
      :chess_pieces_black
    else
      :chess_pieces_white
    end

    if validate_color_tile == :red do

      move_piece =
        socket
        |> Map.get(:assigns)
        |> Map.get(chess_piece_side)
        |> Map.get(attacker_piece_coordinate)
        |> Map.put(:coordinate_alpha, socket.assigns.sel_alpha)
        |> Map.put(:coordinate_no, sel_no)

      #remove attacker piece from old position & put new position (DELETE OLD ATTACKER, NEW OLD ATTACKER COORDINATE)
      updated_pieces_coordinate_attacker =
        socket
        |> Map.get(:assigns)
        |> Map.get(chess_piece_side)
        |> Map.delete(attacker_piece_coordinate)
        |> Map.put(atom_coordinate, move_piece)

      #remove opponent piece from entire map (DELETE OPPONENT)
      updated_pieces_coordinate_opponent =
        if socket.assigns.past_pone_tuple_combo |> elem(2) == true
        and socket.assigns.past_pone_tuple_combo |> elem(0) == atom_coordinate do
          socket
          |> Map.get(:assigns)
          |> Map.get(chess_piece_opponent)
          |> Map.delete(socket.assigns.past_pone_tuple_combo |> elem(1))
        else
          socket
          |> Map.get(:assigns)
          |> Map.get(chess_piece_opponent)
          |> Map.delete(atom_coordinate)
        end

      move_occupant =
        socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.put(:occupant, socket.assigns.attacker_piece_occupant_id)

      remove_attacker_old_coordinate =
        socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(attacker_piece_coordinate)
        |> Map.put(:occupant, nil)

      remove_past_pone =
        if socket.assigns.past_pone_tuple_combo |> elem(2) == true
        and socket.assigns.past_pone_tuple_combo |> elem(0) == atom_coordinate do
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.get(socket.assigns.past_pone_tuple_combo |> elem(1))
          |> Map.put(:occupant, nil)
        end

      updated_tiles_occupant =
        if remove_past_pone != nil and socket.assigns.attacker_piece_role == "pone" do
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.put(atom_coordinate, move_occupant)
          |> Map.put(attacker_piece_coordinate, remove_attacker_old_coordinate)
          |> Map.put(socket.assigns.past_pone_tuple_combo |> elem(1), remove_past_pone)
        else
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.put(atom_coordinate, move_occupant)
          |> Map.put(attacker_piece_coordinate, remove_attacker_old_coordinate)
        end

      # pastpone
      past_pone_tuple_combo = Chess.past_pone(socket.assigns.attacker_piece_role, sel_no, attacker_piece_coordinate_no, attacker_piece_coordinate_alpha, atom_coordinate, chess_piece_side)
      # king checkmate
      opponent_king_location = Chess.locate_king_coordinate(updated_pieces_coordinate_opponent) |> Enum.fetch!(0) #will crash if king is captured!
      attacker_king_location = Chess.locate_king_coordinate(updated_pieces_coordinate_attacker) |> Enum.fetch!(0)
      presume_tiles_attacker = Chess.presume_tiles(updated_pieces_coordinate_attacker, updated_pieces_coordinate_opponent, chess_piece_side, updated_tiles_occupant) |> elem(0)
      presume_tiles_opponent = Chess.presume_tiles(updated_pieces_coordinate_opponent, updated_pieces_coordinate_attacker, chess_piece_opponent, updated_tiles_occupant) |> elem(0)

      king_and_mate = Chess.king_and_mate(Chess.presume_tiles(updated_pieces_coordinate_attacker, updated_pieces_coordinate_opponent, chess_piece_side, updated_tiles_occupant), opponent_king_location)
      the_mate = unless king_and_mate |> List.flatten() |> Enum.filter(& (&1) |> elem(0) != :nope) == [] do
        king_and_mate |> List.flatten() |> Enum.filter(& (&1) |> elem(0) != :nope) |> List.first() |> elem(0)
      end
      the_mate_coordinate =
        unless the_mate == nil do
          for { k, v} <- updated_pieces_coordinate_attacker, v.role_id == Atom.to_string(the_mate) do
            k
          end
        end

      the_mate_coordinate = unless the_mate_coordinate == nil do List.first(the_mate_coordinate) end
      unless the_mate_coordinate == nil do
        IO.inspect mate_steps = Chess.mate_steps(the_mate_coordinate, opponent_king_location) |> Enum.reverse
      end
      # player point of view for attacker/opponent side last layer function, returns value new socket!
      if chess_piece_side == :chess_pieces_white do
        socket = assign(socket,
          selection_toggle: false,
          chess_pieces_white: updated_pieces_coordinate_attacker,
          chess_pieces_black: updated_pieces_coordinate_opponent,
          chess_board_overlay: socket.assigns.old_chess_board_overlay,
          chess_board: updated_tiles_occupant,
          attacker_piece_coordinate_no: nil,
          attacker_piece_coordinate_alpha: nil,
          past_pone_tuple_combo: past_pone_tuple_combo,
          presume_tiles_white: presume_tiles_attacker,
          check_condition_black: opponent_king_location in presume_tiles_attacker,
          check_condition_white: attacker_king_location in presume_tiles_opponent,
          black_king_mate: the_mate,
          black_king_mate_coordinate: the_mate_coordinate )

        { :noreply, socket }
      else
        socket = assign(socket,
          selection_toggle: false,
          chess_pieces_black: updated_pieces_coordinate_attacker,
          chess_pieces_white: updated_pieces_coordinate_opponent,
          chess_board_overlay: socket.assigns.old_chess_board_overlay,
          chess_board: updated_tiles_occupant,
          attacker_piece_coordinate_no: nil,
          attacker_piece_coordinate_alpha: nil,
          past_pone_tuple_combo: past_pone_tuple_combo,
          presume_tiles_black: presume_tiles_attacker,
          check_condition_white: opponent_king_location in presume_tiles_attacker,
          check_condition_black: attacker_king_location in presume_tiles_opponent,
          white_king_mate: the_mate,
          white_king_mate_coordinate: the_mate_coordinate )

        { :noreply, socket }
      end
    else
      socket = assign(socket,
        selection_toggle: false,
        chess_board: socket.assigns.old_chess_board,
        chess_board_overlay: socket.assigns.old_chess_board_overlay)

      { :noreply, socket }
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

    attacker_piece_side =
      case { Map.has_key?(socket.assigns.chess_pieces_white, atom_coordinate), Map.has_key?(socket.assigns.chess_pieces_black, atom_coordinate) } do
        { true, _ } -> :chess_pieces_white
        { _, true } -> :chess_pieces_black
        { _, _} -> nil
      end

    attacker_piece_role = case attacker_piece_side do
      :chess_pieces_white ->
        socket
        |> Map.get(:assigns)
        |> Map.get(:chess_pieces_white)
        |> Map.get(atom_coordinate)
        |> Map.get(:role)
      :chess_pieces_black ->
        socket
        |> Map.get(:assigns)
        |> Map.get(:chess_pieces_black)
        |> Map.get(atom_coordinate)
        |> Map.get(:role)
      _ ->
        nil
    end

    validate_tile_occupancy = if attacker_piece_role != nil do true else false end

    case {validate_tile_occupancy, attacker_piece_role}  do
      { true, "pone" } ->
        pone_shaded =
        if attacker_piece_side == :chess_pieces_white do
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_white,
            socket.assigns.chess_pieces_black,
            false,
            socket.assigns.past_pone_tuple_combo
          )
        else
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_black,
            socket.assigns.chess_pieces_white,
            true,
            socket.assigns.past_pone_tuple_combo
          )
        end
        attacker_piece_occupant_id =
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.get(atom_coordinate)
          |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: pone_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        attacker_piece_coordinate_no: sel_no,
        attacker_piece_coordinate_alpha: sel_alpha,
        attacker_piece_coordinate: atom_coordinate,
        attacker_piece_role: attacker_piece_role,
        attacker_piece_occupant_id: attacker_piece_occupant_id,
        attacker_piece_side: attacker_piece_side )

        {:noreply, socket}
      { true, "rook" } ->
        rook_shaded =
        if attacker_piece_side == :chess_pieces_white do
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_white,
            socket.assigns.chess_pieces_black
          )
        else
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_black,
            socket.assigns.chess_pieces_white
          )
        end
        attacker_piece_occupant_id =
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.get(atom_coordinate)
          |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: rook_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        attacker_piece_coordinate_no: sel_no,
        attacker_piece_coordinate_alpha: sel_alpha,
        attacker_piece_coordinate: atom_coordinate,
        attacker_piece_role: attacker_piece_role,
        attacker_piece_occupant_id: attacker_piece_occupant_id,
        attacker_piece_side: attacker_piece_side )

        {:noreply, socket}
      { true, "knight" } ->
        knight_shaded =
        if attacker_piece_side == :chess_pieces_white do
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_white
          )
        else
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_black
          )
        end
        attacker_piece_occupant_id = socket
        |> Map.get(:assigns)
        |> Map.get(:chess_board)
        |> Map.get(atom_coordinate)
        |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: knight_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        attacker_piece_coordinate_no: sel_no,
        attacker_piece_coordinate_alpha: sel_alpha,
        attacker_piece_coordinate: atom_coordinate,
        attacker_piece_role: attacker_piece_role,
        attacker_piece_occupant_id: attacker_piece_occupant_id,
        attacker_piece_side: attacker_piece_side )

        {:noreply, socket}
      { true, "bishop" } ->
        bishop_shaded =
        if attacker_piece_side == :chess_pieces_white do
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_white,
            socket.assigns.chess_pieces_black
          )
        else
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_black,
            socket.assigns.chess_pieces_white
          )
        end
        attacker_piece_occupant_id =
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.get(atom_coordinate)
          |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: bishop_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        attacker_piece_coordinate_no: sel_no,
        attacker_piece_coordinate_alpha: sel_alpha,
        attacker_piece_coordinate: atom_coordinate,
        attacker_piece_role: attacker_piece_role,
        attacker_piece_occupant_id: attacker_piece_occupant_id,
        attacker_piece_side: attacker_piece_side )

        {:noreply, socket}
      { true, "queen" } ->
        queen_shaded =
        if attacker_piece_side == :chess_pieces_white do
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_white,
            socket.assigns.chess_pieces_black
          )
        else
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_black,
            socket.assigns.chess_pieces_white
          )
        end
        attacker_piece_occupant_id =
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.get(atom_coordinate)
          |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: queen_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        attacker_piece_coordinate_no: sel_no,
        attacker_piece_coordinate_alpha: sel_alpha,
        attacker_piece_coordinate: atom_coordinate,
        attacker_piece_role: attacker_piece_role, #important to reclaim queen roll after undergoing bishop red shade
        attacker_piece_occupant_id: attacker_piece_occupant_id,
        attacker_piece_side: attacker_piece_side )

        {:noreply, socket}
      { true, "king" } ->
        king_shaded =
        if attacker_piece_side == :chess_pieces_white do
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_white,
            socket.assigns.chess_pieces_black,
            attacker_piece_side
          )
        else
          Chess.tile_shade_red(
            sel_alpha,
            sel_no,
            socket.assigns.chess_board,
            attacker_piece_role,
            socket.assigns.chess_pieces_black,
            socket.assigns.chess_pieces_white,
            attacker_piece_side
          )
        end
        attacker_piece_occupant_id =
          socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.get(atom_coordinate)
          |> Map.get(:occupant)
        socket = assign( socket,
        selection_toggle: :true,
        chess_board_overlay: king_shaded,
        old_chess_board_overlay: old_chess_board_overlay,
        old_chess_board: old_chess_board,
        attacker_piece_coordinate_no: sel_no,
        attacker_piece_coordinate_alpha: sel_alpha,
        attacker_piece_coordinate: atom_coordinate,
        attacker_piece_role: attacker_piece_role,
        attacker_piece_occupant_id: attacker_piece_occupant_id,
        attacker_piece_side: attacker_piece_side )

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
    socket = assign(socket, key_press: key, )
    {:noreply, socket}
  end

end
