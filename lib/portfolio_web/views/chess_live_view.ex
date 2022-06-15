defmodule PortfolioWeb.ChessLive do
  require Integer
  use PortfolioWeb, :live_view

  @role_list { "rook", "bishop", "knight", "queen" }

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
      white_king_mate: nil,
      player_turn: :chess_pieces_white,
      check_mate: nil,
      king_made_first_move: [],
      white_rooks_that_made_move: [],
      black_rooks_that_made_move: [],
      pone_promotion_modal_toggle: false,
      pone_promotion_index_pointer: 0,
    )
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

    move_to_red_tile(socket)

  end

  def handle_event("tile_click", %{"sel_no" => sel_no, "sel_alpha" => sel_alpha}, socket)
    when socket.assigns.selection_toggle == true do

    sel_alpha_pointer = get_sel_alpha_pointer(sel_alpha)

    socket = assign(socket, sel_alpha: sel_alpha, sel_no: String.to_integer(sel_no), sel_alpha_pointer: sel_alpha_pointer)
    move_to_red_tile(socket)
  end

  def move_to_red_tile(socket) do
    sel_no = socket.assigns.sel_no
    target_coordinate = String.to_atom(socket.assigns.sel_alpha<>Integer.to_string(sel_no))
    attacker_piece_coordinate = socket.assigns.attacker_piece_coordinate # important! this is the orign coordinate of target_piece to be moved
    attacker_piece_coordinate_no = socket.assigns.attacker_piece_coordinate_no
    attacker_piece_coordinate_alpha = socket.assigns.attacker_piece_coordinate_alpha
    chess_piece_side = Chess.determine_chess_piece_side(attacker_piece_coordinate, socket.assigns.chess_board, :self)
    chess_pieces_opponent = Chess.determine_chess_piece_side(attacker_piece_coordinate, socket.assigns.chess_board, :opponent)
    attacker_piece_role =
      socket
        |> Map.get(:assigns)
        |> Map.get(chess_piece_side)
        |> Map.get(attacker_piece_coordinate)
        |> Map.get(:role)

    validate_coordinate_tile =
      if socket.assigns.sel_alpha in Chess.alpha_list and sel_no in 1..8 do
        true
      else
        false
      end
    validate_color_tile = if validate_coordinate_tile == true do
      case socket
            |> Map.get(:assigns)
            |> Map.get(:chess_board_overlay)
            |> Map.get(target_coordinate)
            |> Map.get(:color) do
        :black -> :black
        :white -> :white
        :red -> :red
        :"#8F00FF" -> :"#8F00FF"
        #_ -> nil
      end
    end

    if validate_color_tile == :red do

      rook_id = if Chess.is_rook?(attacker_piece_role), do: Chess.determine_chess_piece_id(attacker_piece_coordinate, socket.assigns.chess_board)
      king_id = if Chess.is_king?(attacker_piece_role), do: Chess.determine_chess_piece_id(attacker_piece_coordinate, socket.assigns.chess_board)

      king_made_castling =
        if Chess.is_king?(attacker_piece_role) do
          Chess.king_made_two_steps(attacker_piece_coordinate, target_coordinate) |> elem(1)
        else
          false
        end

      updated_pieces_coordinate_attacker =
          Chess.update_chess_pieces_attacker(attacker_piece_coordinate, target_coordinate, socket.assigns[chess_piece_side], king_made_castling)
      #remove opponent piece from entire map (DELETE OPPONENT)
      updated_pieces_coordinate_opponent =
        Chess.update_chess_pieces_opponent(target_coordinate, socket.assigns[chess_pieces_opponent], socket.assigns.past_pone_tuple_combo)

      updated_tiles_occupant =
        Chess.update_chess_board(attacker_piece_coordinate, target_coordinate, socket.assigns.chess_board, attacker_piece_role, socket.assigns.past_pone_tuple_combo, king_made_castling)

      # pastpone
      past_pone_tuple_combo = Chess.past_pone(attacker_piece_role, sel_no, attacker_piece_coordinate_no, attacker_piece_coordinate_alpha, target_coordinate, chess_piece_side)
      # king checkmate
      opponent_king_location = Chess.locate_king_coordinate(updated_pieces_coordinate_opponent) #will crash if king is captured!
      attacker_king_location = Chess.locate_king_coordinate(updated_pieces_coordinate_attacker) #will crash if king is captured!
      presume_tiles_attacker = Chess.presume_tiles(updated_pieces_coordinate_attacker, updated_pieces_coordinate_opponent, chess_piece_side, updated_tiles_occupant) |> elem(0)
      presume_tiles_opponent = Chess.presume_tiles(updated_pieces_coordinate_opponent, updated_pieces_coordinate_attacker, chess_pieces_opponent, updated_tiles_occupant) |> elem(0)
      count_avail_tile = Chess.count_available_tiles(updated_tiles_occupant, updated_pieces_coordinate_attacker, updated_pieces_coordinate_opponent, past_pone_tuple_combo)
      check_mate =
        case { List.foldl(count_avail_tile, 0, fn x, acc -> x + acc end), opponent_king_location in presume_tiles_attacker } do
          { 0, true } -> Chess.determine_chess_piece_side(target_coordinate, updated_tiles_occupant, :opponent)
          { 0, _ } -> :stale_mate
          { _, _ } -> :continue
        end

      pone_reached_end =
        if attacker_piece_role == "pone" and (target_coordinate |> Atom.to_string() |> String.last() |> String.to_integer() == 1 or
        target_coordinate |> Atom.to_string() |> String.last() |> String.to_integer() == 8) do
          :true
        else
          :false
        end

      pone_promotion_initial_piece =
        if pone_reached_end do
          for { _k, v } <- updated_pieces_coordinate_attacker, v.role == "rook" do
            v.role_id
          end |> List.last() |> String.to_charlist() |> List.update_at(3, &(&1 +1))
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
          player_turn: :chess_pieces_black,
          check_mate: check_mate,
          white_rooks_that_made_move:
            if(Chess.is_rook?(attacker_piece_role) and rook_id not in socket.assigns.white_rooks_that_made_move,
              do: [rook_id | socket.assigns.white_rooks_that_made_move],
              else: socket.assigns.white_rooks_that_made_move
            ),
          king_made_first_move:
            if(Chess.is_king?(attacker_piece_role) and king_id not in socket.assigns.king_made_first_move,
              do: [king_id | socket.assigns.king_made_first_move],
              else: socket.assigns.king_made_first_move
            ),
          pone_promotion_modal_toggle: pone_reached_end,
          pone_promotion_initial_piece: pone_promotion_initial_piece,
          selected_coordinate_atom: target_coordinate
        )

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
          player_turn: :chess_pieces_white,
          check_mate: check_mate,
          black_rooks_that_made_move:
            if(Chess.is_rook?(attacker_piece_role) and rook_id not in socket.assigns.black_rooks_that_made_move,
            do: [rook_id | socket.assigns.black_rooks_that_made_move],
            else: socket.assigns.black_rooks_that_made_move
            ),
          king_made_first_move:
            if(Chess.is_king?(attacker_piece_role) and king_id not in socket.assigns.king_made_first_move,
              do: [king_id | socket.assigns.king_made_first_move],
              else: socket.assigns.king_made_first_move
            ),
          pone_promotion_modal_toggle: pone_reached_end,
          pone_promotion_initial_piece: pone_promotion_initial_piece,
          selected_coordinate_atom: target_coordinate
      )
      { :noreply, socket }
      end
    else
      socket = assign(socket,
        selection_toggle: false,
        chess_board: socket.assigns.old_chess_board,
        chess_board_overlay: socket.assigns.old_chess_board_overlay
      )

      { :noreply, socket }
    end
  end

  # first keyup enter press
  def handle_event("tile_selection", %{"key" => key_up}, socket)
    when key_up == "Enter" and socket.assigns.selection_toggle == false and not socket.assigns.pone_promotion_modal_toggle do

    move_tile_selection(socket)

  end

  def handle_event("tile_selection", %{"key" => key_up}, socket)
  when key_up == "Enter" and socket.assigns.selection_toggle == false and socket.assigns.pone_promotion_modal_toggle do

    IO.puts "first keyup enter press modal toggle on"

    pone_modal_confirm(socket)

  end

  # pone promotion modal handle event
  def handle_event("tile_click", %{"sel_no" => sel_no, "sel_alpha" => sel_alpha}, socket)
  when socket.assigns.selection_toggle == false and socket.assigns.pone_promotion_modal_toggle == true do
    IO.puts "modal on. click event"

    pone_modal_confirm(socket)

  end

  def pone_modal_confirm(socket) do
    chess_piece_side = Chess.determine_chess_piece_side(socket.assigns.selected_coordinate_atom, socket.assigns.chess_board, :self)
    chess_pieces_opponent = Chess.determine_chess_piece_side(socket.assigns.selected_coordinate_atom, socket.assigns.chess_board, :opponent)
    chess_pieces_attacker =
      if chess_piece_side == :chess_pieces_white do
        socket.assigns[:chess_pieces_white]
      else
        socket.assigns[:chess_pieces_black]
      end
    target_role = @role_list |> elem(socket.assigns.pone_promotion_index_pointer)
    updated_pieces_promoted_pone =
      Chess.update_chess_pieces_attacker_pone_promote(
        socket.assigns.selected_coordinate_atom,
        chess_pieces_attacker,
        target_role,
        List.to_string(socket.assigns.pone_promotion_initial_piece)
      )

    updated_board_promoted_pone =
      Chess.update_chess_board_pone_promotion(socket.assigns.selected_coordinate_atom, socket.assigns.chess_board, List.to_string(socket.assigns.pone_promotion_initial_piece))

    updated_pieces_coordinate_opponent =
      if chess_piece_side == :chess_pieces_white do
        socket.assigns[:chess_pieces_black]
      else
        socket.assigns[:chess_pieces_white]
      end

    opponent_king_location = Chess.locate_king_coordinate(updated_pieces_coordinate_opponent) #will crash if king is captured!
    attacker_king_location = Chess.locate_king_coordinate(updated_pieces_promoted_pone) #will crash if king is captured!

    presume_tiles_attacker = Chess.presume_tiles(updated_pieces_promoted_pone, updated_pieces_coordinate_opponent, chess_piece_side, updated_board_promoted_pone) |> elem(0)
    presume_tiles_opponent = Chess.presume_tiles(updated_pieces_coordinate_opponent, updated_pieces_promoted_pone, chess_pieces_opponent, updated_board_promoted_pone) |> elem(0)

    count_avail_tile = Chess.count_available_tiles(updated_board_promoted_pone, updated_pieces_promoted_pone, updated_pieces_coordinate_opponent, socket.assigns.past_pone_tuple_combo)
    check_mate =
      case { List.foldl(count_avail_tile, 0, fn x, acc -> x + acc end), opponent_king_location in presume_tiles_attacker } do
        { 0, true } -> Chess.determine_chess_piece_side(socket.assigns.selected_coordinate_atom, updated_board_promoted_pone, :opponent)
        { 0, _ } -> :stale_mate
        { _, _ } -> :continue
      end

    socket =
      if chess_piece_side == :chess_pieces_white do
        assign(socket,
        chess_pieces_white: updated_pieces_promoted_pone,
        pone_promotion_modal_toggle: false,
        chess_board: updated_board_promoted_pone,
        check_condition_black: opponent_king_location in presume_tiles_attacker,
        check_condition_white: attacker_king_location in presume_tiles_opponent,
        check_mate: check_mate
      )
      else
        assign(socket,
        chess_pieces_black: updated_pieces_promoted_pone,
        pone_promotion_modal_toggle: false,
        chess_board: updated_board_promoted_pone,
        check_condition_white: opponent_king_location in presume_tiles_attacker,
        check_condition_black: attacker_king_location in presume_tiles_opponent,
        check_mate: check_mate
        )
      end

    { :noreply, socket }
  end

  def get_sel_alpha_pointer(sel_alpha) do
    case sel_alpha do
      "a" -> 1
      "b" -> 2
      "c" -> 3
      "d" -> 4
      "e" -> 5
      "f" -> 6
      "g" -> 7
      "h" -> 8
      _ -> 0
    end
  end

  def handle_event("tile_click", %{"sel_no" => sel_no, "sel_alpha" => sel_alpha}, socket)
    when socket.assigns.selection_toggle == false and socket.assigns.pone_promotion_modal_toggle == false do

    sel_alpha_pointer = get_sel_alpha_pointer(sel_alpha)

    socket = assign(socket, sel_alpha: sel_alpha, sel_no: String.to_integer(sel_no), sel_alpha_pointer: sel_alpha_pointer)

    move_tile_selection(socket)
  end

  def move_tile_selection(socket) do

    old_chess_board = socket.assigns.chess_board
    old_chess_board_overlay = socket.assigns.chess_board_overlay

    sel_alpha = socket.assigns.sel_alpha
    sel_no = socket.assigns.sel_no

    target_coordinate = String.to_atom(sel_alpha<>Integer.to_string(sel_no))
    attacker_piece_side = Chess.determine_chess_piece_side(target_coordinate, socket.assigns.chess_board, :self)

    if attacker_piece_side == socket.assigns.player_turn do

      attacker_piece_role =                # important must be inside validation rules so that cant be nil tiles.
        socket
        |> Map.get(:assigns)
        |> Map.get(attacker_piece_side)
        |> Map.get(target_coordinate)
        |> Map.get(:role)

      validate_tile_occupancy = if attacker_piece_role != nil do true else false end

      case { validate_tile_occupancy, attacker_piece_role } do
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
              socket.assigns.past_pone_tuple_combo
            )
          end |> elem(0)
          attacker_piece_occupant_id =
            socket
            |> Map.get(:assigns)
            |> Map.get(:chess_board)
            |> Map.get(target_coordinate)
            |> Map.get(:occupant)
          socket = assign( socket,
          selection_toggle: :true,
          chess_board_overlay: pone_shaded,
          old_chess_board_overlay: old_chess_board_overlay,
          old_chess_board: old_chess_board,
          attacker_piece_coordinate_no: sel_no,
          attacker_piece_coordinate_alpha: sel_alpha,
          attacker_piece_coordinate: target_coordinate,
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
          end |> elem(0)
          attacker_piece_occupant_id =
            socket
            |> Map.get(:assigns)
            |> Map.get(:chess_board)
            |> Map.get(target_coordinate)
            |> Map.get(:occupant)
          socket = assign( socket,
          selection_toggle: :true,
          chess_board_overlay: rook_shaded,
          old_chess_board_overlay: old_chess_board_overlay,
          old_chess_board: old_chess_board,
          attacker_piece_coordinate_no: sel_no,
          attacker_piece_coordinate_alpha: sel_alpha,
          attacker_piece_coordinate: target_coordinate,
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
          end |> elem(0)
          attacker_piece_occupant_id = socket
          |> Map.get(:assigns)
          |> Map.get(:chess_board)
          |> Map.get(target_coordinate)
          |> Map.get(:occupant)
          socket = assign( socket,
          selection_toggle: :true,
          chess_board_overlay: knight_shaded,
          old_chess_board_overlay: old_chess_board_overlay,
          old_chess_board: old_chess_board,
          attacker_piece_coordinate_no: sel_no,
          attacker_piece_coordinate_alpha: sel_alpha,
          attacker_piece_coordinate: target_coordinate,
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
          end |> elem(0)
          attacker_piece_occupant_id =
            socket
            |> Map.get(:assigns)
            |> Map.get(:chess_board)
            |> Map.get(target_coordinate)
            |> Map.get(:occupant)
          socket = assign( socket,
          selection_toggle: :true,
          chess_board_overlay: bishop_shaded,
          old_chess_board_overlay: old_chess_board_overlay,
          old_chess_board: old_chess_board,
          attacker_piece_coordinate_no: sel_no,
          attacker_piece_coordinate_alpha: sel_alpha,
          attacker_piece_coordinate: target_coordinate,
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
          end |> elem(0)
          attacker_piece_occupant_id =
            socket
            |> Map.get(:assigns)
            |> Map.get(:chess_board)
            |> Map.get(target_coordinate)
            |> Map.get(:occupant)
          socket = assign( socket,
          selection_toggle: :true,
          chess_board_overlay: queen_shaded,
          old_chess_board_overlay: old_chess_board_overlay,
          old_chess_board: old_chess_board,
          attacker_piece_coordinate_no: sel_no,
          attacker_piece_coordinate_alpha: sel_alpha,
          attacker_piece_coordinate: target_coordinate,
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
              socket.assigns.king_made_first_move,
              socket.assigns.white_rooks_that_made_move
            )
          else
            Chess.tile_shade_red(
              sel_alpha,
              sel_no,
              socket.assigns.chess_board,
              attacker_piece_role,
              socket.assigns.chess_pieces_black,
              socket.assigns.chess_pieces_white,
              socket.assigns.king_made_first_move,
              socket.assigns.black_rooks_that_made_move
            )
          end |> elem(0)
          attacker_piece_occupant_id =
            socket
            |> Map.get(:assigns)
            |> Map.get(:chess_board)
            |> Map.get(target_coordinate)
            |> Map.get(:occupant)
          socket = assign( socket,
          selection_toggle: :true,
          chess_board_overlay: king_shaded,
          old_chess_board_overlay: old_chess_board_overlay,
          old_chess_board: old_chess_board,
          attacker_piece_coordinate_no: sel_no,
          attacker_piece_coordinate_alpha: sel_alpha,
          attacker_piece_coordinate: target_coordinate,
          attacker_piece_occupant_id: attacker_piece_occupant_id,
          attacker_piece_side: attacker_piece_side )

          {:noreply, socket}
        { false, _ } ->
          IO.puts "nil tile/invalid coordinate"
          {:noreply, socket}
      end
    else
      IO.puts "piece invalid"
      {:noreply, socket}
    end

  end

  def handle_event("tile_selection", %{"key" => key_up}, socket)
    when socket.assigns.pone_promotion_modal_toggle == false do
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

  def handle_event("tile_selection", %{"key" => key_up}, socket)
  when socket.assigns.pone_promotion_modal_toggle == true do
    IO.puts "moving selection in modal pone promotion"

    chess_piece_side =
      if socket.assigns.player_turn == :chess_pieces_white do
        :chess_pieces_black
      else
        :chess_pieces_white
      end

    index_pointer =
      case key_up do
        "ArrowLeft" ->
          cond do
            socket.assigns.pone_promotion_index_pointer - 1 in 0..3 -> socket.assigns.pone_promotion_index_pointer - 1
            socket.assigns.pone_promotion_index_pointer - 1 not in 0..3 -> 3
          end
        "ArrowRight" ->
          cond do
            socket.assigns.pone_promotion_index_pointer + 1 in 0..3 -> socket.assigns.pone_promotion_index_pointer + 1
            socket.assigns.pone_promotion_index_pointer + 1 not in 0..3 -> 0
          end
        _ -> 0
      end

    target_role = @role_list |> elem(index_pointer)

    chess_pieces = socket.assigns[chess_piece_side]

    chess_piece_role_id = Chess.chess_role_count_and_role_id(chess_pieces, target_role)

    socket = assign(socket,
      pone_promotion_index_pointer: index_pointer,
      pone_promotion_initial_piece: chess_piece_role_id
      )
    {:noreply, socket}
  end

  def handle_event("key_press", %{"key" => key}, socket) do
    socket = assign(socket, key_press: key, )
    {:noreply, socket}
  end

end


      # king_and_mate = Chess.king_and_mate(Chess.presume_tiles(updated_pieces_coordinate_attacker, updated_pieces_coordinate_opponent, chess_piece_side, updated_tiles_occupant), opponent_king_location)
      # the_mate = unless king_and_mate |> List.flatten() |> Enum.filter(& (&1) |> elem(0) != :nope) == [] do
      #   king_and_mate |> List.flatten() |> Enum.filter(& (&1) |> elem(0) != :nope) |> List.first() |> elem(0)
      # end
      # the_mate_coordinate =
      #   unless the_mate == nil do
      #     for { k, v} <- updated_pieces_coordinate_attacker, v.role_id == Atom.to_string(the_mate) do
      #       k
      #     end
      #   end

      # the_mate_coordinate = unless the_mate_coordinate == nil do List.first(the_mate_coordinate) end
      # mate_steps = unless the_mate_coordinate == nil do
      #   Chess.mate_steps(the_mate_coordinate, opponent_king_location) |> Enum.reverse
      # end
