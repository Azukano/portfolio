defmodule Portfolio.Chess do
  alias Portfolio.ChessTiles
  alias Portfolio.ChessPieces
  require Integer

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
    legal_move = [{coordinate_alpha, 1}, {coordinate_alpha, 2}]

    new_tile = chess_board
    |> Map.get(String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)))
    |> Map.put(:occupant, id)
    chess_board = chess_board
    |> Map.put(String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), new_tile)

    if i >= (pieces_map |> Enum.fetch(j) |> elem(1) |> elem(1)) - 1 do
      piece = ChessPieces.pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, legal_move: legal_move)
      j = j + 1
      if black_switch == false do
        white_pieces = Map.put(white_pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
        spawn_pieces(0, j, white_pieces, black_pieces, black_switch, chess_board)
      else
        black_pieces = Map.put(black_pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
        spawn_pieces(0, j, white_pieces, black_pieces, black_switch, chess_board)
      end
    else
      piece = ChessPieces.pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, legal_move: legal_move)
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
             target_piece_role -> socket.assigns.chess_pieces.tile_id\\:a1.role
             chess_pieces -> socket.assigns.ches_pieces to check what pieces are tiles occupied.
  """
  #PONE TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role, chess_pieces_attacker, chess_pieces_opponent, black_pone, past_pone_tuple_combo)
  when target_piece_role == "pone" do

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

    IO.inspect past_pone_tuple_combo |> elem(3) != pone_side
    IO.inspect Map.has_key?(chess_pieces_opponent, String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)))
    # IO.inspect chess_pieces_attacker
    # IO.inspect chess_pieces_attacker == past_pone_tuple_combo |> elem(3)

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
      if (Map.has_key?(chess_pieces_opponent, String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)))
      or String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)) == past_pone_tuple_combo |> elem(0)) do
        [String.to_atom(<<alpha_binary - 1>><>Integer.to_string(sel_no + black_white_pone_pov)) | targets_atom_list]
      else
        targets_atom_list
      end

    targets_atom_list =
      if (Map.has_key?(chess_pieces_opponent, String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + black_white_pone_pov)))
      or String.to_atom(<<alpha_binary + 1>><>Integer.to_string(sel_no + black_white_pone_pov)) == past_pone_tuple_combo |> elem(0)) do
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
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role, chess_pieces_attacker, chess_pieces_opponent)
  when (target_piece_role == "rook" or target_piece_role == "queen") do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    #1st WAY UP (+) coordinate_no/sel_no
    targets_atom_list_up = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
      (x, acc) when x < 1 and acc == 0 ->
        {:cont, []}
      (x, acc) when x > 0 and acc != 0 ->
        target_atom = if sel_no + x in 1..8 do
          String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
        end
        # main conditional statement checks if there is ally piece ON ITS WAY IMPORTANT!
        unless Map.has_key?(chess_pieces_attacker, target_atom) do
        # sub conditional statement checks if there is enemy piece beyond ON ITS WAY IMPORTANT!
          unless Map.has_key?(chess_pieces_opponent, target_atom) do
            {:cont, [ target_atom | acc ]}
          else
            {:halt, [ target_atom | acc ]}
          end
        else
          {:halt, [ nil | acc ]}
        end
    end)

    #2nd WAY DOWN (-) coordinate_no/sel_no
    targets_atom_list_down = Enum.reduce_while(0..-7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x < 0 and acc != 0 ->
      target_atom = if sel_no + x > 0 and sel_no + x < 9 do
        String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom) do
        unless Map.has_key?(chess_pieces_opponent, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          {:halt, [ target_atom | acc ]}
        end
      else
        {:halt, [ nil | acc ]}
      end
    end)

    #3rd WAY LEFT (-) coordinate_alpha/sel_alpha
    targets_atom_list_left = Enum.reduce_while(0..-7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x < 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>> do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no))
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom) do
        unless Map.has_key?(chess_pieces_opponent, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          {:halt, [ target_atom | acc ]}
        end
      else
        {:halt, [ nil | acc ]}
      end
    end)

    #4th WAY RIGHT (+) coordinate_alpha/sel_alpha
    targets_atom_list_right = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>> do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no))
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom) do
        unless Map.has_key?(chess_pieces_opponent, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          {:halt, [ target_atom | acc ]}
        end
      else
        {:halt, [ nil | acc ]}
      end
    end)

    targets_atom_list = targets_atom_list_up
    |> Enum.concat(targets_atom_list_down)
    |> Enum.concat(targets_atom_list_left)
    |> Enum.concat(targets_atom_list_right)

    new_chess_board_with_red_tile = unless Enum.filter(targets_atom_list, & !is_nil(&1)) == [] do
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
    if target_piece_role == "queen" do
      tile_shade_red(sel_alpha, sel_no, { chess_board, targets_atom_list }, "bishop", chess_pieces_attacker, chess_pieces_opponent)
    else
      new_chess_board_with_red_tile
    end
  end

  #BISHOP TILE RED SHADE
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role, chess_pieces_attacker, chess_pieces_opponent) #chess_board is combo map(chess_board) + list(queen_accumalative list target from rook)
  when target_piece_role == "bishop" do

    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    alpha_binary = for x <- 0..7 do
      if sel_alpha == alpha_list |> Enum.at(x) do
        96 + x + 1
      end
    end |> Enum.find(fn x -> x != nil end )

    targets_atom_list_queen = if is_tuple(chess_board) do chess_board |> elem(1) end
    chess_board = if is_tuple(chess_board) do chess_board |> elem(0) else chess_board end

    #1st WAY DIAGONAL UP-LEFT (-) coordinate_alpha/sel_alpha (+) coordinate_no/sel_no
    targets_atom_list_up_left = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary - x>> > <<96>> and <<alpha_binary - x>> < <<105>>
      and sel_no + x > 0 and sel_no + x < 9 do
        String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no + x))
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom) do
        unless Map.has_key?(chess_pieces_opponent, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          {:halt, [ target_atom | acc ]}
        end
      else
        {:halt, [ nil | acc ]}
      end
    end)

    #2nd WAY DIAGONAL UP-RIGHT (+) coordinate_alpha/sel_alpha (+) coordinate_no/sel_no
    targets_atom_list_up_right = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
      and sel_no + x > 0 and sel_no + x < 9 do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + x))
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom) do
        unless Map.has_key?(chess_pieces_opponent, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          {:halt, [ target_atom | acc ]}
        end
      else
        {:halt, [ nil | acc ]}
      end
    end)

    #3rd WAY DIAGONAL DOWN-RIGHT (+) coordinate_alpha/sel_alpha (-) coordinate_no/sel_no
    targets_atom_list_down_right = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary + x>> > <<96>> and <<alpha_binary + x>> < <<105>>
      and sel_no - x > 0 and sel_no - x < 9 do
        String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no - x))
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom) do
        unless Map.has_key?(chess_pieces_opponent, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          {:halt, [ target_atom | acc ]}
        end
      else
        {:halt, [ nil | acc ]}
      end
    end)

    #4th WAY DIAGONAL DOWN-LEFT (-) coordinate_alpha/sel_alpha (-) coordinate_no/sel_no
    targets_atom_list_down_left = Enum.reduce_while(0..7, 0, fn #generator starts with 0 for acc initiation to [] important!
    (x, acc) when x < 1 and acc == 0 ->
      {:cont, []}
    (x, acc) when x > 0 and acc != 0 ->
      target_atom = if <<alpha_binary - x>> > <<96>> and <<alpha_binary - x>> < <<105>>
      and sel_no - x > 0 and sel_no - x < 9 do
        String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no - x))
      end
      unless Map.has_key?(chess_pieces_attacker, target_atom) do
        unless Map.has_key?(chess_pieces_opponent, target_atom) do
          {:cont, [ target_atom | acc ]}
        else
          {:halt, [ target_atom | acc ]}
        end
      else
        {:halt, [ nil | acc ]}
      end
    end)

    targets_atom_list = targets_atom_list_up_left
    |> Enum.concat(targets_atom_list_up_right)
    |> Enum.concat(targets_atom_list_down_right)
    |> Enum.concat(targets_atom_list_down_left)

    targets_atom_list = unless targets_atom_list_queen == nil do
      targets_atom_list |> Enum.concat(targets_atom_list_queen)
    else
      targets_atom_list
    end

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
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role, chess_pieces_attacker)
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
        and not Map.has_key?(chess_pieces_attacker, target_atom) do
      String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + j))
      else
        nil
      end
    end

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

  #KNIGHT MOVESET
  def tile_shade_red(sel_alpha, sel_no, chess_board, target_piece_role)
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

  @doc """
  returns past_pone coordinate: {:c3, c4} and switch: true/false
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
    past_pone_side_pov =
      if chess_piece_side == :chess_pieces_white do
        1
      else
        -1
      end

    if attacker_piece_role == "pone" and
    (sel_no - attacker_piece_coordinate_no == 2 or sel_no - attacker_piece_coordinate_no == -2) do
      {
        String.to_atom(attacker_piece_coordinate_alpha<>Integer.to_string(attacker_piece_coordinate_no + past_pone_side_pov)),
        atom_coordinate,
        true,
        chess_piece_side
      }
    else
      {
        :nil,
        :nil,
        false,
        chess_piece_side
      }
    end
  end

end

# targets_atom_list = Enum.reduce_while(0..pone_step, 0, fn #generator starts with 0 for acc initiation to [] important!
# (x, acc) when x < 1 and acc == 0 ->
#   {:cont, []}
# (x, acc) when x > 0 and acc != 0 ->
#   target_atom_up =
#   if sel_no + x in 1..8 or sel_no - x in 1..8 do
#     if black_pone == false do
#       String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no + x))
#     else
#       String.to_atom(<<alpha_binary>><>Integer.to_string(sel_no - x))
#     end
#   end
#   target_atom_up_left =
#   if sel_no + x in 1..8 or sel_no - x in 1..8
#   and alpha_binary + x in 97..105 or alpha_binary - x in 97..105 do
#     if black_pone == false do
#       IO.inspect sel_no + x
#       String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no + x))
#     else
#       String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no - x))
#     end
#   end
#   target_atom_up_right =
#   if sel_no + x in 1..8 or sel_no - x in 1..8
#   and alpha_binary + x in 97..105 or alpha_binary - x in 97..105 do
#     if black_pone == false do
#       IO.inspect sel_no + x
#       String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + x))
#     else
#       String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no - x))
#     end
#   end
#   # IO.inspect target_atom_up_left
#   # IO.inspect target_atom_up_right
#   # IO.inspect Map.has_key?(chess_pieces_opponent, target_atom_up_left)
#   # IO.inspect Map.has_key?(chess_pieces_opponent, target_atom_up_right)
#   unless Map.has_key?(chess_pieces_attacker, target_atom_up)
#   or Map.has_key?(chess_pieces_opponent, target_atom_up) do
#     {:cont, [ target_atom_up | acc ]}
#   else
#     if Map.has_key?(chess_pieces_opponent, target_atom_up_left)
#     or Map.has_key?(chess_pieces_opponent, target_atom_up_right) do
#       {:halt, [ target_atom_up_left, target_atom_up_right | acc ]}
#     else
#       {:halt, [ nil | acc ]}
#     end
#   end
# end)


#   target_atom_up_left =
#   if black_pone == false do
#     if sel_no + x in 1..8 and alpha_binary - x in 97..105 do
#       String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no + x))
#     end
#   else
#     if sel_no - x in 1..8 do alpha_binary + x in 97..105
#       String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no - x))
#     end
#   end
#   target_atom_up_right =
#   if black_pone == false do
#     if sel_no + x in 1..8 and alpha_binary - x in 97..105 do
#       String.to_atom(<<alpha_binary + x>><>Integer.to_string(sel_no + x))
#     end
#   else
#     if sel_no - x in 1..8 do alpha_binary + x in 97..105
#       String.to_atom(<<alpha_binary - x>><>Integer.to_string(sel_no - x))
#     end
#   end
