defmodule Portfolio.Chess do
  alias Portfolio.ChessTiles
  alias Portfolio.ChessPieces
  require Integer

  @alpha_list ["a", "b", "c", "d", "e", "f", "g", "h"]
  @valid_tile_list [
    :a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1,
    :a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2,
    :a3, :b3, :c3, :d3, :e3, :f3, :g3, :h3,
    :a4, :b4, :c4, :d4, :e4, :f4, :g4, :h4,
    :a5, :b5, :c5, :d5, :e5, :f5, :g5, :h5,
    :a6, :b6, :c6, :d6, :e6, :f6, :g6, :h6,
    :a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7,
    :a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8,
  ]

  def fill_board(i, j, k, chess_board, overlay) when k > 7 do
    chess_board
  end

  def fill_board(i, j, k, chess_board, overlay) when i > 7 do
    # i 0..7 =  row a1 b1 c1 d1 e1 f1 g1 h1 .. row a8 b8 c8 d8 e8 f8 g8 h8
    i = 0
    k = k + 1 #increase row
    # conditional guard for increasing the row e.a 1st row to 2nd row
    if Integer.is_odd(k) do
      j = 1 #white
      fill_board(i, j, k,chess_board, overlay)
    else
      j = 0 #black
      fill_board(i, j, k,chess_board, overlay)
    end
  end

  def fill_board(i, j, k, chess_board, overlay) when j > 1 do
    fill_board(i, j = 0, k, chess_board, overlay)
  end

  def fill_board(i \\ 0, j \\ 0, k \\ 0, chess_board \\ %{}, overlay \\ :false) do
    # actual chess row and columns & color b/w
    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    no_range = 1..8
    color_tuple = {:black, :white, :nil}

    board = if overlay == :false do
      ChessTiles.tiles(
       coordinate_alpha: elem(Enum.fetch(alpha_list, i), 1),
       color: elem(color_tuple, j),
       coordinate_no: elem(Enum.fetch(no_range, k), 1),
       occupant: nil)
    else
      ChessTiles.tiles(
       coordinate_alpha: elem(Enum.fetch(alpha_list, i), 1),
       color: elem(color_tuple, 2),
       coordinate_no: elem(Enum.fetch(no_range, k), 1))
    end

    # !IMPORTANT Map.put 2nd arg :a1 concatinated alpha + no
    chess_board = Map.put(chess_board, String.to_atom(elem(Enum.fetch(alpha_list, i), 1) <> Integer.to_string(elem(Enum.fetch(no_range, k), 1))), board)

    #call itself to iterate
    fill_board(i + 1, j + 1, k, chess_board, overlay)
  end

  #Guard Function for Spawn pieces when j index pointer reaches 5 it is over bishop(1) ... rook(5)
  def spawn_pieces(i, j, white_pieces, black_pieces, black_switch, chess_board)
  when j > 5 and black_switch == true do
    {white_pieces, black_pieces, chess_board}
  end

  #Guard Function for Spawn pieces when j index pointer reaches 5 it is over bishop(1) ... rook(5)
  def spawn_pieces(i, j, white_pieces, black_pieces, black_switch, chess_board)
  when j > 5 and black_switch == false do
    spawn_pieces(0, 0, white_pieces, black_pieces, true, chess_board)
  end

  @doc """
  SPAWN PIECES Initial Position done. Position after movement TLDR;
  """
  def spawn_pieces(i \\ 0, j \\ 0, white_pieces \\ %{}, black_pieces \\ %{}, black_switch \\ false, chess_board \\ fill_board) do

    # combo map role + count of piece
    pieces_map = %{bishop: 2, king: 1, knight: 2, pone: 8, queen: 1, rook: 2}

    role  = pieces_map
      |> Enum.fetch(j)                                         # index pointer in pieces_map
      |> elem(1)                                               # index pointer in tuple returned by fetch {:ok, x} always X so 1!
      |> elem(0)                                               # index pointer in tuple returned inside (i)element of map 0 = name; 1 = count of map
      |> Atom.to_string()                                      # return text type
    coordinate_alpha = elem(piece_coordinate(role, i, black_switch), 0)      # return string poistion a .. h
    coordinate_no = elem(piece_coordinate(role, i, black_switch), 1)         # return integer poistion 1 .. 8

    id = pieces_id(role, i, black_switch)

    new_tile = chess_board
    |> Map.get(String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)))
    |> Map.put(:occupant, id)
    chess_board = chess_board
    |> Map.put(String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), new_tile)

    if i >= (pieces_map |> Enum.fetch(j) |> elem(1) |> elem(1)) - 1 do
      piece = ChessPieces.pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, role_id: id)
      j = j + 1
      if black_switch == false do
        white_pieces = Map.put(white_pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
        spawn_pieces(0, j, white_pieces, black_pieces, black_switch, chess_board)
      else
        black_pieces = Map.put(black_pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
        spawn_pieces(0, j, white_pieces, black_pieces, black_switch, chess_board)
      end
    else
      piece = ChessPieces.pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, role_id: id)
      if black_switch == false do
        white_pieces = Map.put(white_pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
        spawn_pieces(i + 1, j, white_pieces, black_pieces, black_switch, chess_board)
      else
        black_pieces = Map.put(black_pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
        spawn_pieces(i + 1, j, white_pieces, black_pieces, black_switch, chess_board)
      end
    end
  end

  @doc """
  INITIAL POSITION of pieces.
  """
  def piece_coordinate(role, i, black_switch) do
    officials_behind = if black_switch == false do 1 else 8 end
    pone_front = if black_switch == false do 2 else 7 end
    case role do
      "pone" ->
        {<<97+i>>, pone_front}
      "knight" ->
        if i > 0 do
          col = i + 4
          {<<98+col>>, officials_behind}
        else
          {<<98+i>>, officials_behind}
        end
      "bishop" ->
        if i > 0 do
          col = i + 2
          {<<99+col>>, officials_behind}
        else
          {<<99+i>>, officials_behind}
        end
      "rook" ->
        if i > 0 do
          col = i + 6
          {<<97+col>>, officials_behind}
        else
          {<<97+i>>, officials_behind}
        end
      "queen" ->
        {<<100+i>>, officials_behind}
      "king" ->
        {<<101+i>>, officials_behind}
    end
  end

  def pieces_id(role, i, black_switch) do
    if black_switch == false do
      case role do
        "bishop" -> "w-b"<>Integer.to_string(i + 1)
        "king" -> "w-k"<>Integer.to_string(i + 1)
        "knight" -> "w-n"<>Integer.to_string(i + 1)
        "pone" -> "w-p"<>Integer.to_string(i + 1)
        "queen" -> "w-q"<>Integer.to_string(i + 1)
        "rook" -> "w-r"<>Integer.to_string(i + 1)
      end
    else
      case role do
        "bishop" -> "b-b"<>Integer.to_string(i + 1)
        "king" -> "b-k"<>Integer.to_string(i + 1)
        "knight" -> "b-n"<>Integer.to_string(i + 1)
        "pone" -> "b-p"<>Integer.to_string(i + 1)
        "queen" -> "b-q"<>Integer.to_string(i + 1)
        "rook" -> "b-r"<>Integer.to_string(i + 1)
      end
    end
  end

  @doc """
  TILE SHADE RED a function to shade red overlay board(above the real chess_board) it simply trackdown
  moves for pieces when player hit enter during live view mode interaction
  accepting: sel_alpha -> hitting enter will get the initial targeted piece's coordinate on Alphabetic Axis
             sel_no -> hitting enter will get the initial targeted piece's coordinate on Numeric Axis
             chess_board -> passed in value is from initiated chess_board! or old_chess_board if game
             is already started and will keep using old_chess_board \\ returns new_chess_board to be passed
             on overlay_chess_board so that it shades tiles available beneath its original chess_board
             attacker_piece_role -> socket.assigns.chess_pieces.tile_id\\:a1.role
             chess_pieces -> socket.assigns.ches_pieces to check what pieces are tiles occupied.
  """
  #PONE TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, attacker_piece_role, chess_pieces_attacker, chess_pieces_opponent, black_pone, past_pone_tuple_combo)
  when attacker_piece_role == "pone" do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    pone_step = case {black_pone, sel_no} do
      { false, 2 } -> 2
      { false, _ } -> 1
      { true, 7 } -> 2
      { true, _ } -> 1
    end

    targets_atom_list = Enum.reduce_while(0..pone_step, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom_up =
      if black_pone == false do
        if sel_no + x in 1..8 do
          String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
        end
      else
        if sel_no - x in 1..8 do
          String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no - x))
        end
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom_up)
      or Map.has_key?(chess_pieces_opponent, target_atom_up) do
        {:cont, [ target_atom_up | acc ]}
      else
        {:halt, [ nil | acc ]}
      end
    end)

    black_white_pone_pov = if black_pone == false do 1 else -1 end

    pone_side =
      if black_pone == true do
        :chess_pieces_black
      else
        :chess_pieces_white
      end

    # pone attack up-left / up-right first 2 pattern match is for past-pone another 2 is for normal attack
    targets_atom_list =
      if pone_side != past_pone_tuple_combo |> elem(3) and
      (Map.has_key?(chess_pieces_opponent, String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)))
      or String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)) == past_pone_tuple_combo |> elem(0)) do
        [String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)) | targets_atom_list]
      else
        targets_atom_list
      end

    targets_atom_list =
      if pone_side != past_pone_tuple_combo |> elem(3) and
      (Map.has_key?(chess_pieces_opponent, String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + black_white_pone_pov)))
      or String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + black_white_pone_pov)) == past_pone_tuple_combo |> elem(0)) do
        [String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + black_white_pone_pov)) | targets_atom_list]
      else
        targets_atom_list
      end

    targets_atom_list =
      if Map.has_key?(chess_pieces_opponent, String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov))) do
        [String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)) | targets_atom_list]
      else
        targets_atom_list
      end

    targets_atom_list =
      if Map.has_key?(chess_pieces_opponent, String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + black_white_pone_pov))) do
        [String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + black_white_pone_pov)) | targets_atom_list]
      else
        targets_atom_list
      end

    unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
      Enum.reduce(targets_atom_list, 0, fn (tile_id, acc) ->
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
      # ELSE STATEMENT pone_step1 = nil, move list returned [] empty list
      pone_step1 =
        chess_board
        |> Map.get(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)))
        |> Map.put(:color, :"#8F00FF")
      chess_board
      |> Map.put(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)), pone_step1)
    end
  end

  #ROOK TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, attacker_piece_role, chess_pieces_attacker, chess_pieces_opponent)
  when attacker_piece_role == "rook" do

    alpha_binary = for x <- 0..7 do
      if sel_alpha == @alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    #1st&2nd WAY UP (+) DOWN (-) ROW coordinate_no/sel_no
    targets_atom_list_up = moves_up(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    targets_atom_list_down = moves_down(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #3rd&4th WAY LEFT (-) RIGHT (+) COLUMN coordinate_alpha/sel_alpha
    targets_atom_list_left = moves_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    targets_atom_list_right = moves_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)

    targets_atom_list = targets_atom_list_up
    |> Enum.concat(targets_atom_list_down)
    |> Enum.concat(targets_atom_list_left)
    |> Enum.concat(targets_atom_list_right)

    unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
      Enum.reduce(targets_atom_list, 0, fn
      (tile_id, acc) ->
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
  end

  defp moves_up(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do
    Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
      (x, acc) when x == 0 and acc == 0 ->
        {:cont, []}
      (x, acc) when acc != 0 ->
        target_atom = move_up_down(alpha_binary, sel_no, x)
        # main conditional statement checks if there is ally piece ON ITS WAY IMPORTANT!
        unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        # sub conditional statement checks if there is enemy piece beyond ON ITS WAY IMPORTANT!
          unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
            { :cont, [ target_atom | acc ] }
          else
            { :halt, [ target_atom | acc ] }
          end
        else
          if presume_tile_mode == false do
            { :halt, [ nil | acc ] }
          else
            {:halt, [ target_atom | acc ]}
          end
        end
    end)
  end

  defp moves_down(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do
    Enum.reduce_while(0..-7, 0, fn #generator starts with 0 for acc initiation to [] important!
      (x, acc) when x == 0 and acc == 0 ->
        {:cont, []}
      (x, acc) when acc != 0 ->
        target_atom = move_up_down(alpha_binary, sel_no, x)
        # main conditional statement checks if there is ally piece ON ITS WAY IMPORTANT!
        unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        # sub conditional statement checks if there is enemy piece beyond ON ITS WAY IMPORTANT!
          unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
            { :cont, [ target_atom | acc ] }
          else
            { :halt, [ target_atom | acc ] }
          end
        else
          if presume_tile_mode == false do
            { :halt, [ nil | acc ] }
          else
            {:halt, [ target_atom | acc ]}
          end
        end
    end)
  end

  defp moves_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do
    Enum.reduce_while(0..-7, 0, fn #generator starts with 0 for acc initiation to [] important!
      (x, acc) when x == 0 and acc == 0 ->
        {:cont, []}
      (x, acc) when acc != 0 ->
        target_atom = move_left_right(alpha_binary, sel_no, x)
        # main conditional statement checks if there is ally piece ON ITS WAY IMPORTANT!
        unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        # sub conditional statement checks if there is enemy piece beyond ON ITS WAY IMPORTANT!
          unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
            {:cont, [ target_atom | acc ]}
          else
            { :halt, [ target_atom | acc ] }
          end
        else
          if presume_tile_mode == false do
            { :halt, [ nil | acc ] }
          else
            {:halt, [ target_atom | acc ]}
          end
        end
    end)
  end

  defp moves_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do
    Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
      (x, acc) when x == 0 and acc == 0 ->
        {:cont, []}
      (x, acc) when acc != 0 ->
        target_atom = move_left_right(alpha_binary, sel_no, x)
        # main conditional statement checks if there is ally piece ON ITS WAY IMPORTANT!
        unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        # sub conditional statement checks if there is enemy piece beyond ON ITS WAY IMPORTANT!
          unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
            {:cont, [ target_atom | acc ]}
          else
            { :halt, [ target_atom | acc ] }
          end
        else
          if presume_tile_mode == false do
            { :halt, [ nil | acc ] }
          else
            {:halt, [ target_atom | acc ]}
          end
        end
    end)
  end

  defp move_up_down(alpha_binary, sel_no, x) do
    if sel_no + x in 1..8 do
      String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
    end
  end

  defp move_left_right(alpha_binary, sel_no, x) do
    if alpha_binary + x in 97..104 do
      String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no))
    end
  end

  #BISHOP TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, attacker_piece_role, chess_pieces_attacker, chess_pieces_opponent)
  when attacker_piece_role == "bishop" do

    alpha_binary = for x <- 0..7 do
      if sel_alpha == @alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    #1st WAY DIAGONAL UP-LEFT (-) coordinate_alpha/sel_alpha (+) coordinate_no/sel_no
    targets_atom_list_up_left = moves_up_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #2nd WAY DIAGONAL UP-RIGHT (+) coordinate_alpha/sel_alpha (+) coordinate_no/sel_no
    targets_atom_list_up_right = moves_up_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #3rd WAY DIAGONAL DOWN-RIGHT (+) coordinate_alpha/sel_alpha (-) coordinate_no/sel_no
    targets_atom_list_down_right = moves_down_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #4th WAY DIAGONAL DOWN-LEFT (-) coordinate_alpha/sel_alpha (-) coordinate_no/sel_no
    targets_atom_list_down_left = moves_down_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)

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

  defp moves_up_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do

    Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x == 0 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = move_up_left(alpha_binary, sel_no, x)
      unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
          {:cont, [ target_atom | acc ]}
        else
          { :halt, [ target_atom | acc ] }
        end
      else
        if presume_tile_mode == false do
          { :halt, [ nil | acc ] }
        else
          {:halt, [ target_atom | acc ]}
        end
      end
    end)
  end

  defp moves_up_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do

    Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x == 0 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = move_up_right(alpha_binary, sel_no, x)
      unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
          {:cont, [ target_atom | acc ]}
        else
          { :halt, [ target_atom | acc ] }
        end
      else
        if presume_tile_mode == false do
          { :halt, [ nil | acc ] }
        else
          {:halt, [ target_atom | acc ]}
        end
      end
    end)
  end

  defp moves_down_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do
    Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x == 0 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = move_down_right(alpha_binary, sel_no, x)
      unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
          {:cont, [ target_atom | acc ]}
        else
          { :halt, [ target_atom | acc ] }
        end
      else
        if presume_tile_mode == false do
          { :halt, [ nil | acc ] }
        else
          {:halt, [ target_atom | acc ]}
        end
      end
    end)
  end

  defp moves_down_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent, presume_tile_mode \\ false) do

    Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x == 0 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = move_down_left(alpha_binary, sel_no, x)
      unless Map.has_key?(chess_pieces_attacker, target_atom) or target_atom not in @valid_tile_list do
        unless Map.has_key?(chess_pieces_opponent, target_atom) or target_atom not in @valid_tile_list do
          {:cont, [ target_atom | acc ]}
        else
          { :halt, [ target_atom | acc ] }
        end
      else
        if presume_tile_mode == false do
          { :halt, [ nil | acc ] }
        else
          {:halt, [ target_atom | acc ]}
        end
      end
    end)
  end

  defp move_up_left(alpha_binary, sel_no, x) do
    if alpha_binary - x in 97..104 and sel_no + x in 1..8 do
      String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no + x))
    end
  end

  defp move_up_right(alpha_binary, sel_no, x) do
    if alpha_binary + x in 97..104 and sel_no + x in 1..8 do
      String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + x))
    end
  end

  defp move_down_right(alpha_binary, sel_no, x) do
    if alpha_binary + x in 97..104 and sel_no - x in 1..8 do
      String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no - x))
    end
  end

  defp move_down_left(alpha_binary, sel_no, x) do
    if alpha_binary - x in 97..104 and sel_no - x in 1..8 do
      String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no - x))
    end
  end

  #QUEEN MOVESET
  def tile_shade_red(sel_alpha, sel_no, chess_board, attacker_piece_role, chess_pieces_attacker, chess_pieces_opponent)
  when attacker_piece_role == "queen" do

    alpha_binary = for x <- 0..7 do
      if sel_alpha == @alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    #1st&2nd WAY UP (+) DOWN (-) ROW coordinate_no/sel_no
    targets_atom_list_up = moves_up(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    targets_atom_list_down = moves_down(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #3rd&4th WAY LEFT (-) RIGHT (+) COLUMN coordinate_alpha/sel_alpha
    targets_atom_list_left = moves_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    targets_atom_list_right = moves_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)

    targets_atom_list = targets_atom_list_up
    |> Enum.concat(targets_atom_list_down)
    |> Enum.concat(targets_atom_list_left)
    |> Enum.concat(targets_atom_list_right)

    #1st WAY DIAGONAL UP-LEFT (-) coordinate_alpha/sel_alpha (+) coordinate_no/sel_no
    targets_atom_list_up_left = moves_up_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #2nd WAY DIAGONAL UP-RIGHT (+) coordinate_alpha/sel_alpha (+) coordinate_no/sel_no
    targets_atom_list_up_right = moves_up_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #3rd WAY DIAGONAL DOWN-RIGHT (+) coordinate_alpha/sel_alpha (-) coordinate_no/sel_no
    targets_atom_list_down_right = moves_down_right(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)
    #4th WAY DIAGONAL DOWN-LEFT (-) coordinate_alpha/sel_alpha (-) coordinate_no/sel_no
    targets_atom_list_down_left = moves_down_left(alpha_binary, sel_no, chess_pieces_attacker, chess_pieces_opponent)

    targets_atom_list = targets_atom_list
    |> Enum.concat(targets_atom_list_up_left)
    |> Enum.concat(targets_atom_list_up_right)
    |> Enum.concat(targets_atom_list_down_right)
    |> Enum.concat(targets_atom_list_down_left)

    unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
      Enum.reduce(targets_atom_list, 0, fn (tile_id, acc) ->
        queen_step1 = if tile_id != nil do
          chess_board
          |> Map.get(tile_id)
          |> Map.put(:color, :red)
        else
          nil
        end
        if acc == 0 and queen_step1 != nil do
          chess_board |> Map.put(tile_id, queen_step1)
        else
          if queen_step1 != nil do
            acc |> Map.put(tile_id, queen_step1)
          else
            acc
          end
        end
      end)
    else
      queen_step1 =
        chess_board
        |> Map.get(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)))
        |> Map.put(:color, :"#8F00FF")
      chess_board
      |> Map.put(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)), queen_step1)
    end

  end

  #KING MOVESET
  def tile_shade_red(sel_alpha, sel_no, chess_board, attacker_piece_role, chess_pieces_attacker, chess_pieces_opponent, attacker_piece_side)
  when attacker_piece_role == "king" do

    alpha_binary = for x <- 0..7 do
      if sel_alpha == @alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    opponent_piece_side = if attacker_piece_side == :chess_pieces_white do :chess_pieces_black else :chess_pieces_white end

    chess_pieces_attacker_no_king = chess_pieces_attacker |> Map.delete(String.to_atom(sel_alpha<>Integer.to_string(sel_no)))
    chess_board_removed_king = chess_board |> Map.delete(String.to_atom(sel_alpha<>Integer.to_string(sel_no)))

    presume_tiles_opponent = presume_tiles(chess_pieces_opponent, chess_pieces_attacker_no_king, opponent_piece_side, chess_board_removed_king) |> elem(0)

    targets_atom_list = move_king(alpha_binary, sel_no, chess_pieces_attacker, presume_tiles_opponent)

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

  defp move_king(alpha_binary, sel_no, chess_pieces_attacker, presume_tiles_opponent \\ nil) do
    unless presume_tiles_opponent == nil do
      for x <- -1..1, j <- -1..1 do
        target_atom = String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
        if target_atom in @valid_tile_list
          and target_atom != String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no))
          and not Map.has_key?(chess_pieces_attacker, target_atom)
          and target_atom not in presume_tiles_opponent do
          String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
        end
      end
    else
      for x <- -1..1, j <- -1..1 do
        target_atom = String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
        if target_atom in @valid_tile_list
          and target_atom != String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)) do
          String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
        end
      end
    end
  end

  #KNIGHT MOVESET
  def tile_shade_red(sel_alpha, sel_no, chess_board, attacker_piece_role, chess_pieces_attacker)
  when attacker_piece_role == "knight" do

    alpha_binary = for x <- 0..7 do
      if sel_alpha == @alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    targets_atom_list = move_knight(alpha_binary, sel_no, chess_pieces_attacker)

    unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
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
    else
      knight_step1 =
        chess_board
        |> Map.get(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)))
        |> Map.put(:color, :"#8F00FF")
      chess_board
      |> Map.put(String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no)), knight_step1)
    end
  end

  defp move_knight(alpha_binary, sel_no, chess_pieces_attacker, presume_tile_mode \\ false) do
    if presume_tile_mode == false do
      for x <- -2..2, j <- -2..2 do
        if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
          and sel_no + j > 0 and sel_no + j < 9
          and String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) != String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no))
          and (
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 2>><>Integer.to_string(sel_no + 1)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no - 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 2>><>Integer.to_string(sel_no - 1)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 2>><>Integer.to_string(sel_no + 1)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no - 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 2>><>Integer.to_string(sel_no - 1))
          ) and not Map.has_key?(chess_pieces_attacker, String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))) do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
        end
      end |> Enum.filter(& !is_nil(&1))
    else
      for x <- -2..2, j <- -2..2 do
        if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
          and sel_no + j > 0 and sel_no + j < 9
          and String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) != String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no))
          and (
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 2>><>Integer.to_string(sel_no + 1)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no - 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 2>><>Integer.to_string(sel_no - 1)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary - 2>><>Integer.to_string(sel_no + 1)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no - 2)) or
            String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j)) == String.to_atom(<<alpha_binary + 2>><>Integer.to_string(sel_no - 1))
          ) do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
        end
      end
    end |> Enum.filter(& !is_nil(&1))
  end

  @doc """
  returns past_pone coordinate: {:c3, c4} and switch: true/false and chess_piece_side: chess_pieces_white/black
  attacker_piece_role: "pone" or "bishop" in general this function only accept "pone".
  sel_no the currect selector sel_no.
  attacker_piece_coordinate_no origin place of the attacker piece to be moved. (NUMERIC)
  attacker_piece_coordinate_alpha origin place of the attacher piece to be moved. (ALPHA)
  atom_coordinate selected tile id in atom.
  chess_piece_side: either :chess_pieces_white or :chess_pieces_black to determine what the past pone coordinates are
  +1 from original attacker coordinate's numeric if white
  -1 from original attacker cooridnate's numeric if black
  """
  def past_pone(attacker_piece_role, sel_no, attacker_piece_coordinate_no, attacker_piece_coordinate_alpha, atom_coordinate, chess_piece_side) do

    past_pone_side_pov = if chess_piece_side == :chess_pieces_white do 1 else -1 end

    if attacker_piece_role == "pone" and
    (sel_no - attacker_piece_coordinate_no == 2 or sel_no - attacker_piece_coordinate_no == -2) do
      {
        String.to_atom(attacker_piece_coordinate_alpha<>Integer.to_string(attacker_piece_coordinate_no + past_pone_side_pov)),
        atom_coordinate,
        true,
        chess_piece_side
      }
    else
      { :nil, :nil, false, chess_piece_side }
    end
  end

  defp move_attack_pone(alpha_binary, sel_no, chess_piece_side) do
    pone_pov = if chess_piece_side == :chess_pieces_white do 1 else - 1 end
    for x <- -1..1 do
      unless x == 0 or alpha_binary + x not in 97..104 or sel_no + x not in 1..8 do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + pone_pov))
      end
    end
  end

  @doc """
  presumption mode of opponent's pieces to get pre allocated tiles so that attacker's king
  can not set foot on tiles that presumptively took over by opponent's pieces.
  """
  def presume_tiles(chess_pieces_attacker, chess_pieces_opponent, chess_piece_side, chess_board) do

    presume_tiles_pone = for { piece_tile_id, piece } <- chess_pieces_attacker, piece.role == "pone" do
      piece_coordinate_alpha = Atom.to_string(piece_tile_id) |> String.first()
      piece_coordinate_alpha = for x <- 0..7 do
        if piece_coordinate_alpha == @alpha_list |> Enum.at(x) do
          96 + x + 1
        end
      end |> Enum.find(fn x -> x != nil end )
      piece_coordinate_no = Atom.to_string(piece_tile_id) |> String.last() |> String.to_integer()
      piece_id = chess_board[String.to_atom(<<piece_coordinate_alpha>><>Integer.to_string(piece_coordinate_no))].occupant
      { String.to_atom(piece_id), move_attack_pone(piece_coordinate_alpha, piece_coordinate_no, chess_piece_side) }
    end

    presume_tiles_knight = for { piece_tile_id, piece } <- chess_pieces_attacker, piece.role == "knight" do
      piece_coordinate_alpha = Atom.to_string(piece_tile_id) |> String.first()
      piece_coordinate_alpha = for x <- 0..7 do
        if piece_coordinate_alpha == @alpha_list |> Enum.at(x) do
          96 + x + 1
        end
      end |> Enum.find(fn x -> x != nil end )
      piece_coordinate_no = Atom.to_string(piece_tile_id) |> String.last() |> String.to_integer()
      piece_id = chess_board[String.to_atom(<<piece_coordinate_alpha>><>Integer.to_string(piece_coordinate_no))].occupant
      { String.to_atom(piece_id), move_knight(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, true) }
    end

    presume_tiles_rook = for { piece_tile_id, piece } <- chess_pieces_attacker, piece.role == "rook" do
      piece_coordinate_alpha = Atom.to_string(piece_tile_id) |> String.first()
      piece_coordinate_alpha = for x <- 0..7 do
        if piece_coordinate_alpha == @alpha_list |> Enum.at(x) do
          96 + x + 1
        end
      end |> Enum.find(fn x -> x != nil end )
      piece_coordinate_no = Atom.to_string(piece_tile_id) |> String.last() |> String.to_integer()
      piece_id = chess_board[String.to_atom(<<piece_coordinate_alpha>><>Integer.to_string(piece_coordinate_no))].occupant

      #1st&2nd WAY UP (+) DOWN (-) ROW coordinate_no/sel_no
      piece_moves_up = moves_up(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_down = moves_down(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      #3rd&4th WAY LEFT (-) RIGHT (+) COLUMN coordinate_alpha/sel_alpha
      piece_moves_left = moves_left(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_right = moves_right(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))

      piece_moves = piece_moves_up
      |> Enum.concat(piece_moves_down)
      |> Enum.concat(piece_moves_left)
      |> Enum.concat(piece_moves_right)

      { String.to_atom(piece_id), piece_moves }
    end

    presume_tiles_bishop = for { piece_tile_id, piece } <- chess_pieces_attacker, piece.role == "bishop" do
      piece_coordinate_alpha = Atom.to_string(piece_tile_id) |> String.first()
      piece_coordinate_alpha = for x <- 0..7 do
        if piece_coordinate_alpha == @alpha_list |> Enum.at(x) do
          96 + x + 1
        end
      end |> Enum.find(fn x -> x != nil end )
      piece_coordinate_no = Atom.to_string(piece_tile_id) |> String.last() |> String.to_integer()
      piece_id = chess_board[String.to_atom(<<piece_coordinate_alpha>><>Integer.to_string(piece_coordinate_no))].occupant

      piece_moves_up_left = moves_up_left(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_up_right = moves_up_right(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_down_right = moves_down_right(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_down_left = moves_down_left(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))

      piece_moves = piece_moves_up_left
      |> Enum.concat(piece_moves_up_right)
      |> Enum.concat(piece_moves_down_right)
      |> Enum.concat(piece_moves_down_left)

      { String.to_atom(piece_id), piece_moves }
    end

    presume_tiles_queen = for { piece_tile_id, piece } <- chess_pieces_attacker, piece.role == "queen" do
      piece_coordinate_alpha = Atom.to_string(piece_tile_id) |> String.first()
      piece_coordinate_alpha = for x <- 0..7 do
        if piece_coordinate_alpha == @alpha_list |> Enum.at(x) do
          96 + x + 1
        end
      end |> Enum.find(fn x -> x != nil end )
      piece_coordinate_no = Atom.to_string(piece_tile_id) |> String.last() |> String.to_integer()
      piece_id = chess_board[String.to_atom(<<piece_coordinate_alpha>><>Integer.to_string(piece_coordinate_no))].occupant

      piece_moves_up = moves_up(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_down = moves_down(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_left = moves_left(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_right = moves_right(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_up_left = moves_up_left(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_up_right = moves_up_right(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_down_right = moves_down_right(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))
      piece_moves_down_left = moves_down_left(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker, chess_pieces_opponent, true) |> Enum.reverse() |> Enum.filter(& !is_nil(&1))

      piece_moves = piece_moves_up
      |> Enum.concat(piece_moves_left)
      |> Enum.concat(piece_moves_right)
      |> Enum.concat(piece_moves_down)
      |> Enum.concat(piece_moves_up_left)
      |> Enum.concat(piece_moves_up_right)
      |> Enum.concat(piece_moves_down_right)
      |> Enum.concat(piece_moves_down_left)

      { String.to_atom(piece_id), piece_moves }
    end

    presume_tiles_king = for { piece_tile_id, piece } <- chess_pieces_attacker, piece.role == "king" do
      piece_coordinate_alpha = Atom.to_string(piece_tile_id) |> String.first()
      piece_coordinate_alpha = for x <- 0..7 do
        if piece_coordinate_alpha == @alpha_list |> Enum.at(x) do
          96 + x + 1
        end
      end |> Enum.find(fn x -> x != nil end )
      piece_coordinate_no = Atom.to_string(piece_tile_id) |> String.last() |> String.to_integer()
      piece_id = chess_board[String.to_atom(<<piece_coordinate_alpha>><>Integer.to_string(piece_coordinate_no))].occupant

      piece_moves = move_king(piece_coordinate_alpha, piece_coordinate_no, chess_pieces_attacker)

      { String.to_atom(piece_id), piece_moves }
    end

    # IO.inspect presume_tiles_pone, label: "Ponies"
    # IO.inspect presume_tiles_knight, label: "Knights"
    # IO.inspect presume_tiles_bishop, label: "Bishops"
    # IO.inspect presume_tiles_rook, label: "Rooks"
    # IO.inspect presume_tiles_queen, label: "Queen"
    # IO.inspect presume_tiles_king, label: "King"

    presume_tiles =
      presume_tiles_pone
      |> Enum.concat(presume_tiles_knight)
      |> Enum.concat(presume_tiles_rook)
      |> Enum.concat(presume_tiles_bishop)
      |> Enum.concat(presume_tiles_queen)
      |> Enum.concat(presume_tiles_king)

    presume_tiles = for x <- presume_tiles do
      x |> elem(1)
      end |> List.flatten() |> Enum.filter(& !is_nil(&1)) |> Enum.uniq()

    { presume_tiles, presume_tiles_pone, presume_tiles_rook, presume_tiles_knight, presume_tiles_bishop, presume_tiles_queen, presume_tiles_king }
  end

  def locate_king_coordinate(chess_pieces_opponent) do
    for { piece_tile_id, piece } <- chess_pieces_opponent, piece.role == "king" do
      piece_tile_id
    end
  end

  def king_and_mate(presume_tiles_attacker, opponent_king_location) do
    for x <- 1..6 do
      if x < 5 do
        Enum.reduce_while(presume_tiles_attacker |> elem(x), [], fn
          (x, acc) ->
            mate = x |> elem(0)
            element = x |> elem(1)
            if opponent_king_location not in element do
              { :cont, [ { :nope, [] } | acc ] }
            else
              { :cont, [ { mate, element } | acc ] }
            end
        end)
      else
        mate = presume_tiles_attacker |> elem(x) |> Enum.fetch(0) |> elem(1) |> elem(0)
        element = presume_tiles_attacker |> elem(x) |> Enum.fetch(0) |> elem(1) |> elem(1)
        if opponent_king_location in element do
          [ { mate, element } ]
        else
          [ { :nope, [] } ]
        end
      end
    end
  end

  def mate_steps(the_mate_coordinate, opponent_king_location) do
    mate_coordinate_alpha = Atom.to_string(the_mate_coordinate) |> String.first()
    mate_coordinate_alpha = for x <- 0..7 do
      if mate_coordinate_alpha == @alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )
    mate_coordinate_no = Atom.to_string(the_mate_coordinate) |> String.last() |> String.to_integer()

    opponent_king_coordinate_alpha = Atom.to_string(opponent_king_location) |> String.first()
    opponent_king_coordinate_alpha = for x <- 0..7 do
      if opponent_king_coordinate_alpha == @alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )
    opponent_king_coordinate_no = Atom.to_string(opponent_king_location) |> String.last() |> String.to_integer()

    IO.puts("mate_coordinate: #{mate_coordinate_alpha} #{mate_coordinate_no}")
    IO.puts("king_coordinate: #{opponent_king_coordinate_alpha} #{opponent_king_coordinate_no}")

    alpha_diff = opponent_king_coordinate_alpha - mate_coordinate_alpha
    no_diff = opponent_king_coordinate_no - mate_coordinate_no

    left_or_right_switch = cond do
        alpha_diff in -2..-7  -> :left
        alpha_diff in 7..2    -> :right
        alpha_diff == -1      -> :close_to_king_left
        alpha_diff == 1       -> :close_to_king_right
        alpha_diff == 0       -> :up_down
      end
    up_or_down_switch = cond do
        no_diff in 7..2   -> :up
        no_diff in -2..-7 -> :down
        no_diff == -1     -> :close_to_king_down
        no_diff == 1      -> :close_to_king_up
        no_diff == 0      -> :left_right
      end
    IO.inspect up_or_down_switch
    IO.inspect left_or_right_switch
    case {  up_or_down_switch, left_or_right_switch } do
      { :up, :up_down } -> mate_steps_up_down(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, 1, 7)
      { :down, :up_down } -> mate_steps_up_down(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, -1, -7)
      { :left_right, :left } -> mate_steps_left_right(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, -1, -7)
      { :left_right, :right } -> mate_steps_left_right(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, 1, 7)
      { :up, :left } -> mate_steps_up_left_down_right(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, 1, 7)
      { :down, :right } -> mate_steps_up_left_down_right(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, -1, -7)
      { :down, :left } -> mate_steps_up_right_down_left(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, -1, -7)
      { :up, :right } -> mate_steps_up_right_down_left(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, 1, 7)
      { _, _ } -> [:ok]
    end

  end

  def mate_steps_up_down(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, x, y) do
    Enum.reduce_while(x..y, [], fn
      (x, acc) ->
        mate_steps_atom = String.to_atom(<<mate_coordinate_alpha>><>Integer.to_string(mate_coordinate_no + x))
        if mate_steps_atom == opponent_king_location do
          { :halt, acc }
        else
          { :cont, [mate_steps_atom | acc] }
        end
    end)
  end

  def mate_steps_left_right(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, x, y) do
    Enum.reduce_while(x..y, [], fn
      (x, acc) ->
        IO.inspect mate_steps_atom = String.to_atom(<<mate_coordinate_alpha + x>><>Integer.to_string(mate_coordinate_no))
        if mate_steps_atom == opponent_king_location do
          { :halt, acc }
        else
          { :cont, [mate_steps_atom | acc] }
        end
    end)
  end

  def mate_steps_up_left_down_right(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, x, y) do
    Enum.reduce_while(x..y, [], fn
      (x, acc) ->
        mate_steps_atom = String.to_atom(<<mate_coordinate_alpha - x>><>Integer.to_string(mate_coordinate_no + x))
        if mate_steps_atom == opponent_king_location do
          { :halt, acc }
        else
          { :cont, [mate_steps_atom | acc] }
        end
    end)
  end

  def mate_steps_up_right_down_left(mate_coordinate_alpha, mate_coordinate_no, opponent_king_location, x, y) do
    Enum.reduce_while(x..y, [], fn
      (x, acc) ->
        mate_steps_atom = String.to_atom(<<mate_coordinate_alpha + x>><>Integer.to_string(mate_coordinate_no + x))
        if mate_steps_atom == opponent_king_location do
          { :halt, acc }
        else
          { :cont, [mate_steps_atom | acc] }
        end
    end)
  end

end
