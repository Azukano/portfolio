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
        pone_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
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
        rook_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
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
        knight_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1, target_piece_role)
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
        bishop_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
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
        queen_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, target_piece_role, socket.assigns.chess_pieces)
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
        king_shaded = tile_shade_red(sel_alpha, sel_no, socket.assigns.chess_board, 1, target_piece_role, socket.assigns.chess_pieces)
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
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role, chess_pieces)
  when target_piece_role == "pone" do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    pone_step = if sel_no > 2 do
      1
    else
      2
    end

    targets_atom_list_up = Enum.reduce_while(0..pone_step, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if sel_no + x > 0 and sel_no + x < 9 do
        String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        {:halt, [ target_atom | acc ]}
      end
    end)

    # targets_atom_list_up = if sel_no == 2 do
    #   #MOVE FORWARD 2 TILES
    #   for x <- 1..2 do
    #     if sel_no + x > 0 and sel_no + x < 9 and
    #     not Map.has_key?(chess_pieces, String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))) do
    #       String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
    #     end
    #   end
    # else
    #   #MOVE FORWARD 1 TILE
    #   for x <- 1..1 do
    #     if sel_no + x > 0 and sel_no + x < 9 and
    #     not Map.has_key?(chess_pieces, String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))) do
    #       String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
    #     end
    #   end
    # end

    IO.inspect targets_atom_list_up

    # new_chess_board_with_red_tile =
    #   Enum.reduce(targets_atom_list_up, 0, fn (tile_id, acc) ->
    #     pone_step1 = chess_board
    #     |> Map.get(tile_id)
    #     |> Map.put(:color, :red)
    #     if acc == 0 do
    #       chess_board |> Map.put(tile_id, pone_step1)
    #     else
    #       acc |> Map.put(tile_id, pone_step1)
    #     end
    #   end)

    new_chess_board_with_red_tile = unless Enum.filter(targets_atom_list_up, & !is_nil(&1)) == [] do
      Enum.reduce(targets_atom_list_up, 0, fn (tile_id, acc) ->
        pone_step1 = if tile_id != nil do
          chess_board
          |> Map.get(tile_id)
          |> Map.put(:color, :red)
        else
          nil
        end
        if acc == 0 and pone_step1 != nil do
          chess_board |> Map.put(tile_id, pone_step1)
        else
          if pone_step1 != nil do
            acc |> Map.put(tile_id, pone_step1)
          else
            acc
          end
        end
      end)
    else
      pone_step1 =
        chess_board
        |> Map.get(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)))
        |> Map.put(:color, :"#8F00FF")
      chess_board
      |> Map.put(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)), pone_step1)
    end
    if target_piece_role == "queen" do
      IO.puts "@@@@ QUEEN"
      tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, "bishop", chess_pieces)
    else
      new_chess_board_with_red_tile
    end

    new_chess_board_with_red_tile
  end

  #ROOK TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role, chess_pieces)
  when (target_piece_role == "rook" or target_piece_role == "queen") do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    # IO.inspect Enum.reduce(1..7, 0, fn (x, acc) ->
    #   target_atom = if sel_no + x > 0 and sel_no + x < 9 do
    #     String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
    #   end
    #   acc = if acc == 0 do
    #     []
    #   else
    #     acc
    #   end
    #   [ target_atom | acc ]
    # end)

    #1st WAY UP
    targets_atom_list_up = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
      (x, acc) when x < 1 and acc == 0 ->
        {:cont, []}
      (x, acc) when x > 0 and acc != 0 ->
        target_atom = if sel_no + x > 0 and sel_no + x < 9 do
          String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
        end
        unless Map.has_key?(chess_pieces, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          target_atom = nil
          {:halt, [ target_atom | acc ]}
        end
    end)

    #2nd WAY DOWN
    targets_atom_list_down = Enum.reduce_while(0..-7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x < 0 and acc != 0 ->
      target_atom = if sel_no + x > 0 and sel_no + x < 9 do
        String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        IO.inspect target_atom
        {:halt, [ target_atom | acc ]}
      end
    end)

    #3rd WAY LEFT
    targets_atom_list_left = Enum.reduce_while(0..-7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x < 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>> do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        {:halt, [ target_atom | acc ]}
      end
    end)

    #4th WAY RIGHT
    targets_atom_list_right = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>> do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        IO.inspect target_atom
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        {:halt, [ target_atom | acc ]}
      end
    end)

    # IO.inspect max

    #1st WAY UP
    # targets_atom_list_up = for x <- 1..7 do
    #   if sel_no + x > 0 and sel_no + x < 9 do
    #     String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
    #   end
    # end

    #2nd WAY DOWN
    # targets_atom_list_down = for x <- -1..-7 do
    #   if sel_no + x > 0 and sel_no + x < 9 do
    #     String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
    #   end
    # end

    #3rd WAY LEFT
    # targets_atom_list_left = for x <- -1..-7 do
    #   if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>> do
    #     String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no))
    #   end
    # end

    #4th WAY DOWN
    # targets_atom_list_right = for x <- 1..7 do
    #   if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>> do
    #     String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no))
    #   end
    # end

    targets_atom_list = targets_atom_list_up
    |> Enum.concat(targets_atom_list_down)
    |> Enum.concat(targets_atom_list_left)
    |> Enum.concat(targets_atom_list_right)

    new_chess_board_with_red_tile = unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
      Enum.reduce(targets_atom_list, 0, fn (tile_id, acc) ->
        rook_step1 = if tile_id != nil do
          chess_board
          |> Map.get(tile_id)
          |> Map.put(:color, :red)
        else
          nil
        end
        if acc == 0 and rook_step1 != nil do
          chess_board |> Map.put(tile_id, rook_step1)
        else
          if rook_step1 != nil do
            acc |> Map.put(tile_id, rook_step1)
          else
            acc
          end
        end
      end)
    else
      rook_step1 =
        chess_board
        |> Map.get(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)))
        |> Map.put(:color, :"#8F00FF")
      chess_board
      |> Map.put(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)), rook_step1)
    end
    if target_piece_role == "queen" do
      IO.puts "@@@@ QUEEN"
      tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, "bishop", chess_pieces)
    else
      new_chess_board_with_red_tile
    end
  end

  #BISHOP TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role, chess_pieces)
  when target_piece_role == "bishop" do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    #1st WAY DIAGONAL UP-LEFT
    # targets_atom_list_up_left = for x <- 1..7 do
    #   if <<alpha_binary - x>> > <<96>> and <<alpha_binary - x>> < <<105>>
    #   and sel_no + x > 0 and sel_no + x < 9 do
    #     String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no + x))
    #   end
    # end

    #1st WAY DIAGONAL UP-LEFT
    targets_atom_list_up_left = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary - x>> > <<96>> and <<alpha_binary - x>> < <<105>>
      and sel_no + x > 0 and sel_no + x < 9 do
        String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no + x))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        {:halt, [ target_atom | acc ]}
      end
    end)

    #2nd WAY DIAGONAL UP-RIGHT
    # targets_atom_list_up_right = for x <- 1..7 do
    #   if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
    #   and sel_no + x > 0 and sel_no + x < 9 do
    #     String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + x))
    #   end
    # end

    #2nd WAY DIAGONAL UP-RIGHT
    targets_atom_list_up_right = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
      and sel_no + x > 0 and sel_no + x < 9 do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + x))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        {:halt, [ target_atom | acc ]}
      end
    end)

    #3rd WAY DIAGONAL DOWN-RIGHT
    # targets_atom_list_down_right = for x <- 1..7 do
    #   if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
    #   and sel_no - x > 0 and sel_no - x < 9 do
    #     String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no - x))
    #   end
    # end

    #3rd WAY DIAGONAL DOWN-RIGHT
    targets_atom_list_down_right = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
      and sel_no - x > 0 and sel_no - x < 9 do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no - x))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        {:halt, [ target_atom | acc ]}
      end
    end)

    #4th WAY DIAGONAL DOWN-LEFT
    # targets_atom_list_down_left = for x <- 1..7 do
    #   if <<alpha_binary - x>> > <<96>> and <<alpha_binary - x>> < <<105>>
    #   and sel_no - x > 0 and sel_no - x < 9 do
    #     String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no - x))
    #   end
    # end

    #4th WAY DIAGONAL DOWN-LEFT
    targets_atom_list_down_left = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary - x>> > <<96>> and <<alpha_binary - x>> < <<105>>
      and sel_no - x > 0 and sel_no - x < 9 do
        String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no - x))
      end
      unless Map.has_key?(chess_pieces, target_atom) do
        {:cont, [ target_atom | acc ]}
      else
        target_atom = nil
        {:halt, [ target_atom | acc ]}
      end
    end)

    targets_atom_list = targets_atom_list_up_left
    |> Enum.concat(targets_atom_list_up_right)
    |> Enum.concat(targets_atom_list_down_right)
    |> Enum.concat(targets_atom_list_down_left)

    unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
      Enum.reduce(targets_atom_list, 0, fn (tile_id, acc) ->
        bishop_step1 = if tile_id != nil do
          chess_board
          |> Map.get(tile_id)
          |> Map.put(:color, :red)
        else
          nil
        end
        if acc == 0 and bishop_step1 != nil do
          chess_board |> Map.put(tile_id, bishop_step1)
        else
          if bishop_step1 != nil do
            acc |> Map.put(tile_id, bishop_step1)
          else
            acc
          end
        end
      end)
    else
      bishop_step1 =
        chess_board
        |> Map.get(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)))
        |> Map.put(:color, :"#8F00FF")
      chess_board
      |> Map.put(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)), bishop_step1)
    end
  end

  #KING MOVESET
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role, chess_pieces)
  when target_piece_role == "king" and i > 9 do
    chess_board
  end

  #KING MOVESET
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role, chess_pieces)
  when target_piece_role == "king" do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    target_piece_coordinate_atom = String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no))

    targets_atom_list = for x <- -1..1, j <- -1..1 do
      target_atom = String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
      if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
        and sel_no + j > 0 and sel_no + j < 9
        and target_atom != target_piece_coordinate_atom
        and not Map.has_key?(chess_pieces, target_atom) do
      String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
      else
        nil
      end
    end

    targets_atom_list # [nil, :d1, :d2, nil, nil, :e2, nil, :f1, :f2]

    # Enum.reduce(targets_atom_list, 0, fn (tile_id, acc) ->
    #   king_step1 = if tile_id != nil do
    #     chess_board
    #     |> Map.get(tile_id)
    #     |> Map.put(:color, :red)
    #   else
    #     nil
    #   end
    #   if acc == 0 and king_step1 != nil do
    #     chess_board |> Map.put(tile_id, king_step1)
    #   else
    #     if king_step1 != nil do
    #       acc |> Map.put(tile_id, king_step1)
    #     else
    #       acc
    #     end
    #   end
    # end)
    unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
      Enum.reduce(targets_atom_list, 0, fn (tile_id, acc) ->
        king_step1 = if tile_id != nil do
          chess_board
          |> Map.get(tile_id)
          |> Map.put(:color, :red)
        else
          nil
        end
        if acc == 0 and king_step1 != nil do
          chess_board |> Map.put(tile_id, king_step1)
        else
          if king_step1 != nil do
            acc |> Map.put(tile_id, king_step1)
          else
            acc
          end
        end
      end)
    else
      king_step1 =
        chess_board
        |> Map.get(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)))
        |> Map.put(:color, :"#8F00FF")
      chess_board
      |> Map.put(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)), king_step1)
    end
  end

  #KNIGHT MOVESET GUARD C
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when i > 25 and target_piece_role == "knight" do
    chess_board
  end
  #KNIGHT MOVESET
  def tile_shade_red(sel_alpha, sel_no, chess_board, i, target_piece_role)
  when target_piece_role == "knight" do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    target_piece_coordinate_atom = String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no))

    targets_atom_list = for x <- -2..2, j <- -2..2 do
      if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
        and sel_no + j > 0 and sel_no + j < 9
        and String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) != target_piece_coordinate_atom
        and (
          String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + 2))
          or String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 2>><>Integer.to_string(sel_no + 1))
          or String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no - 2))
          or String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 2>><>Integer.to_string(sel_no - 1))
          or String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + 2))
          or String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 2>><>Integer.to_string(sel_no + 1))
          or String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no - 2))
          or String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 2>><>Integer.to_string(sel_no - 1))
        ) do
      String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
      else
        nil
      end
    end

    Enum.reduce(targets_atom_list, 0, fn (tile_id, acc) ->
      knight_step1 = if tile_id != nil do
        chess_board
        |> Map.get(tile_id)
        |> Map.put(:color, :red)
      else
        nil
      end
      if acc == 0 and knight_step1 != nil do
        chess_board |> Map.put(tile_id, knight_step1)
      else
        if knight_step1 != nil do
          acc |> Map.put(tile_id, knight_step1)
        else
          acc
        end
      end
    end)
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

###### LONG HAND VERSION ######

#target_atom = targets_atom_list |> Enum.fetch(i - 1) |> elem(1) # 1st element to nth element

# rook_step_1 =
#   if target_atom != nil do #if statement to nullify the pattern match during recursion if value is nil
#   chess_board
#   |> Map.get(target_atom)
#   |> Map.put(:color, :red)
# end

#  new_chess_board_with_red_tile = if rook_step_1 != nil do #avoid passing in nil value to the map (will error)
#    chess_board
#    |> Map.put(target_atom, rook_step_1)
#  else
#    chess_board
#  end

#  tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)

###### ~~~~~~~~~~~~~~~~~~ ######

###### SHORT HAND VERSION ######

# new_chess_board_with_red_tile =
#   for target_atom <- targets_atom_list, target_atom != nil do
#     king_step1 = chess_board
#     |> Map.get(target_atom)
#     |> Map.put(:color, :red)
#     chess_board
#     |> Map.put(target_atom, king_step1)
#   end

# new_chess_board_with_red_tile = Enum.fetch(new_chess_board_with_red_tile, 4) |> elem(1)
# IO.inspect new_chess_board_with_red_tile.e2

###### ~~~~~~~~~~~~~~~~~~ ######


# target_atom = targets_atom_list |> Enum.fetch(i - 1) |> elem(1) # 1st element to nth element

# bishop_step_1 =
#   if target_atom != nil do #if statement to nullify the pattern match during recursion if value is nil
#   chess_board
#   |> Map.get(target_atom)
#   |> Map.put(:color, :red)
# end

# new_chess_board_with_red_tile = if bishop_step_1 != nil do #avoid passing in nil value to the map (will error)
#   chess_board
#   |> Map.put(target_atom, bishop_step_1)
# else
#     chess_board
# end

# tile_shade_red(sel_alpha, sel_no, new_chess_board_with_red_tile, i + 1, target_piece_role)
