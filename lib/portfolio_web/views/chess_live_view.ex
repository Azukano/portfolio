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

    atom_coordinate = String.to_atom(sel_alpha<>Integer.to_string(sel_no))

    # target_piece_role = if atom_coordinate in Map.keys(socket.assigns.chess_pieces) do
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
        pone_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1, target_piece_role)
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
        rook_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1, target_piece_role)
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
        IO.puts "knight"
        {:noreply, socket}
      { true, "bishop" } ->
        bishop_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1, target_piece_role)
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
        queen_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1, target_piece_role)
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
        target_piece_role: target_piece_role,
        target_piece_occupant_id: target_piece_occupant_id )

        {:noreply, socket}
      { true, "king" } ->
        king_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1, target_piece_role)
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

  #PONE TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when i > 2 and target_piece_role == "pone" do
    chess_board
  end

  #PONE TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when target_piece_role == "pone" do
    target_piece_coordinate_atom = String.to_atom(sel_alpha<>Integer.to_string(sel_no + i))
    pone_step_1 = chess_board
    |> Map.get(target_piece_coordinate_atom)
    |> Map.put(:color, :red)

    i = if sel_no > 2 do
      i = i + 1
    else
      i
    end
    new_chess_board_with_red_tile = chess_board
    |> Map.put(target_piece_coordinate_atom, pone_step_1)
    tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
  end

  #QUEEN TILE RED EXTENSION
  def tile_shade_red_extension(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when i > 8 and target_piece_role == "queen" do
    bishop_1st_way(sel_alpha, sel_no, chess_board, 1, target_piece_role)
  end

  #ROOK TILE RED
  def tile_shade_red_extension(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when i > 8 and (target_piece_role == "rook" or target_piece_role == "queen") do
    chess_board
  end

  #ROOK TILE RED SHADE VERTICAL (NUMERIC)
  def tile_shade_red_extension(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when (target_piece_role == "rook" or target_piece_role == "queen") do

    target_piece_coordinate_atom = String.to_atom(sel_alpha<>Integer.to_string(1 + i))

    i = if target_piece_coordinate_atom == String.to_atom(sel_alpha<>Integer.to_string(sel_no)) do
      i = i + 1
    else
      i
    end

    target_piece_coordinate_atom = String.to_atom(sel_alpha<>Integer.to_string(1 + i))

    rook_step_1  = if (1 + i) < 9 do
      chess_board
      |> Map.get(target_piece_coordinate_atom)
      |> Map.put(:color, :red)
    end

    new_chess_board_with_red_tile = if rook_step_1 != nil do
      chess_board
      |> Map.put(target_piece_coordinate_atom, rook_step_1)
    else
      chess_board
    end

    tile_shade_red_extension(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
  end

  #ROOK TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when i > 8 and (target_piece_role == "rook" or target_piece_role == "queen") do
    tile_shade_red_extension(sel_alpha, sel_no, chess_board, 0, target_piece_role)
  end

  #ROOK TILE RED SHADE HORIZONTAL (ALPHA)
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when (target_piece_role == "rook" or target_piece_role == "queen") do

    target_piece_coordinate_atom = String.to_atom(<<96+i>><>Integer.to_string(sel_no))

    i = if target_piece_coordinate_atom == String.to_atom(sel_alpha<>Integer.to_string(sel_no)) do
      i = i + 1
    else
      i
    end

    target_piece_coordinate_atom = String.to_atom(<<96+i>><>Integer.to_string(sel_no))

    rook_step_1  = if <<96+i>> < "i" do
      chess_board
      |> Map.get(target_piece_coordinate_atom)
      |> Map.put(:color, :red)
    end

    new_chess_board_with_red_tile = if rook_step_1 != nil do
      chess_board
      |> Map.put(target_piece_coordinate_atom, rook_step_1)
    else
      chess_board
    end

    tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
  end

  #BISHOP TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when target_piece_role == "bishop" do
    up_left_diagonal = bishop_1st_way(sel_alpha, sel_no, chess_board, i, target_piece_role)
    #up_right_diagonal = bishop_2nd_way(sel_alpha, sel_no, chess_board, i)
    #down_left_diagonal = bishop_3rd_way(sel_alpha, sel_no, chess_board, i)
    #down_right_diagonal = bishop_4th_way(sel_alpha, sel_no, chess_board, i)
  end

  #BISHOP TILE RED 1st WAY UP-LEFT DIAGONAL (-) ALPHA (+) NUMERIC
  def bishop_1st_way(sel_alpha, sel_no, chess_board, i, target_piece_role) when i > 7 do
    bishop_2nd_way(sel_alpha, sel_no, chess_board, 1, target_piece_role)
  end

  #BISHOP TILE RED 1st WAY UP-LEFT DIAGONAL (-) ALPHA (+) NUMERIC
  def bishop_1st_way(sel_alpha, sel_no, chess_board, i, target_piece_role) do
    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    target_piece_coordinate_atom = String.to_atom(<<alpha_binary - i>><>Integer.to_string(sel_no + i))

    bishop_step_1 = if <<alpha_binary - i>> > <<96>> and <<alpha_binary - i>> < <<105>>
    and (sel_no + i) < 9 and (sel_no + i) > 0  do
      chess_board
      |> Map.get(target_piece_coordinate_atom)
      |> Map.put(:color, :red)
    end

    new_chess_board_with_red_tile = if bishop_step_1 != nil do
      chess_board
      |> Map.put(target_piece_coordinate_atom, bishop_step_1)
    else
      chess_board
    end

    bishop_1st_way(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
  end

  #BISHOP TILE RED 2nd WAY UP-RIGHT DIAGONAL (+) ALPHA (+) NUMERIC
  def bishop_2nd_way(sel_alpha, sel_no, chess_board, i, target_piece_role) when i > 7 do
    bishop_3rd_way(sel_alpha, sel_no, chess_board, 1, target_piece_role)
  end

  #BISHOP TILE RED 2nd WAY UP-RIGHT DIAGONAL (+) ALPHA (+) NUMERIC
  def bishop_2nd_way(sel_alpha, sel_no, chess_board, i, target_piece_role) do
    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    target_piece_coordinate_atom = String.to_atom(<<alpha_binary + i>><>Integer.to_string(sel_no + i))

    bishop_step_1 = if <<alpha_binary + i>> > <<96>> and <<alpha_binary + i>> < <<105>>
    and (sel_no + i) < 9 and (sel_no + i) > 0  do
      chess_board
      |> Map.get(target_piece_coordinate_atom)
      |> Map.put(:color, :red)
    end

    new_chess_board_with_red_tile = if bishop_step_1 != nil do
      chess_board
      |> Map.put(target_piece_coordinate_atom, bishop_step_1)
    else
      chess_board
    end

    bishop_2nd_way(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
  end

  #BISHOP TILE RED 3rd WAY DOWN-LEFT DIAGONAL (-) ALPHA (-) NUMERIC
  def bishop_3rd_way(sel_alpha, sel_no, chess_board, i, target_piece_role) when i > 7 do
    bishop_4th_way(sel_alpha, sel_no, chess_board, 1, target_piece_role)
  end

  #BISHOP TILE RED 3rd WAY DOWN-LEF DIAGONAL (-) ALPHA (-) NUMERIC
  def bishop_3rd_way(sel_alpha, sel_no, chess_board, i, target_piece_role) do
    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    target_piece_coordinate_atom = String.to_atom(<<alpha_binary - i>><>Integer.to_string(sel_no - i))

    bishop_step_1 =
      if <<alpha_binary - i>> > <<96>> and <<alpha_binary - i>> < <<105>>
      and (sel_no - i) < 9 and (sel_no - i) > 0  do
      chess_board
      |> Map.get(target_piece_coordinate_atom)
      |> Map.put(:color, :red)
    end

    new_chess_board_with_red_tile = if bishop_step_1 != nil do
      chess_board
      |> Map.put(target_piece_coordinate_atom, bishop_step_1)
    else
      chess_board
    end

    bishop_3rd_way(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
  end

  #BISHOP TILE RED 4th WAY DOWN-RIGHT DIAGONAL (+) ALPHA (-) NUMERIC
  def bishop_4th_way(sel_alpha, sel_no, chess_board, i, target_piece_role) when i > 7 do
    chess_board
  end

  #BISHOP TILE RED 4th WAY DOWN-RIGHT DIAGONAL (+) ALPHA (-) NUMERIC
  def bishop_4th_way(sel_alpha, sel_no, chess_board, i, target_piece_role) do
    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    target_piece_coordinate_atom = String.to_atom(<<alpha_binary + i>><>Integer.to_string(sel_no - i))

    bishop_step_1 =
      if <<alpha_binary + i>> > <<96>> and <<alpha_binary + i>> < <<105>>
      and (sel_no - i) < 9 and (sel_no - i) > 0  do
      chess_board
      |> Map.get(target_piece_coordinate_atom)
      |> Map.put(:color, :red)
    end

    new_chess_board_with_red_tile = if bishop_step_1 != nil do
      chess_board
      |> Map.put(target_piece_coordinate_atom, bishop_step_1)
    else
      chess_board
    end

    bishop_4th_way(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
  end

  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when target_piece_role == "king" and i > 9 do
    chess_board
  end

  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when target_piece_role == "king" do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    target_piece_coordinate_atom = String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no))

    targets_atom_list = for x <- -1..1, j <- -1..1 do
      if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
        and sel_no + j > 0 and sel_no + j < 9
        and String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) != target_piece_coordinate_atom do
      String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
      else
        nil
      end
    end

    IO.inspect targets_atom_list # [nil, :d1, :d2, nil, nil, :e2, nil, :f1, :f2]

    target_atom = targets_atom_list |> Enum.fetch(i - 1) |> elem(1) # 1st element to 9th element

    king_step_1 =
      if target_atom != nil do #if statement to nullify the pattern match during recursion if value is nil
      chess_board
      |> Map.get(target_atom)
      |> Map.put(:color, :red)
    end

    new_chess_board_with_red_tile = if king_step_1 != nil do #avoid passing in nil value to the map (will error)
      chess_board
      |> Map.put(target_atom, king_step_1)
    else
      chess_board
    end

    tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
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

# case {sel_tile_occupied, target_piece_role}  do
#   { true, "pone" } ->
#     pone_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1)
#     socket = assign( socket,
#     selection_toggle: :true,
#     chess_board_overlay: pone_shaded,
#     old_chess_board_overlay: old_chess_board_overlay,
#     old_chess_board: old_chess_board,
#     target_piece_coordinate: atom_coordinate,
#     target_piece_role: target_piece_role )

#     {:noreply, socket}

#   { false, _ } ->
#     IO.puts "@@@"
#     {:noreply, socket}
# end
