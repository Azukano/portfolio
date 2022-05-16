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
  def spawn_pieces(i, j, pieces, chess_board) when j > 5 do
    IO.puts "End of process"
    {pieces, chess_board}
  end

  @doc """
  SPAWN PIECES Initial Position done. Position after movement TLDR;
  """
  def spawn_pieces(i \\ 0, j \\ 0, pieces \\ %{}, chess_board \\ fill_board) do
    # combo map role + count of piece
    pieces_map = %{bishop: 2, king: 1, knight: 2, pone: 8, queen: 1, rook: 2}

    role  = pieces_map
      |> Enum.fetch(j)                                         # index pointer in pieces_map
      |> elem(1)                                               # index pointer in tuple returned by fetch {:ok, x} always X so 1!
      |> elem(0)                                               # index pointer in tuple returned inside (i)element of map 0 = name; 1 = count of map
      |> Atom.to_string()                                      # return text type
    coordinate_alpha = elem(piece_coordinate(role, i), 0)      # return string poistion a .. h
    coordinate_no = elem(piece_coordinate(role, i), 1)         # return integer poistion 1 .. 8

    id = pieces_id(role, i)
    legal_move = [{coordinate_alpha, 1}, {coordinate_alpha, 2}]

    new_tile = chess_board |> Map.get(String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no))) |> Map.put(:occupant, id)
    chess_board = chess_board |> Map.put(String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), new_tile)
    if i >= (pieces_map |> Enum.fetch(j) |> elem(1) |> elem(1)) - 1 do
      # IO.inspect role
      # IO.puts "piece: #{pieces_map |> Enum.fetch(j) |> elem(1) |> elem(0)}: #{pieces_map |> Enum.fetch(0) |> elem(1) |> elem(1)}"
      # IO.puts "IF #{i} \ #{j}"
      piece = ChessPieces.pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, legal_move: legal_move)
      pieces = Map.put(pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
      j = j + 1
      spawn_pieces(0, j, pieces, chess_board)
    else
      #IO.inspect role
      #IO.puts "piece: #{pieces_map |> Enum.fetch(j) |> elem(1) |> elem(0)}: #{pieces_map |> Enum.fetch(0) |> elem(1) |> elem(1)}"
      #IO.puts "ELSE #{i} \ #{j}"
      piece = ChessPieces.pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, legal_move: legal_move)
      pieces = Map.put(pieces, String.to_atom(coordinate_alpha<>Integer.to_string(coordinate_no)), piece)
      spawn_pieces(i + 1, j, pieces, chess_board)
    end
  end

  @doc """
  INITIAL POSITION of pieces.
  """
  def piece_coordinate(role, i) do
    # IO.puts i
    case role do
      "pone" ->
        {<<97+i>>, 2}
      "knight" ->
        if i > 0 do
          col = i + 4
          {<<98+col>>, 1}
        else
          {<<98+i>>, 1}
        end
      "bishop" ->
        if i > 0 do
          col = i + 2
          {<<99+col>>, 1}
        else
          {<<99+i>>, 1}
        end
      "rook" ->
        if i > 0 do
          col = i + 6
          {<<97+col>>, 1}
        else
          {<<97+i>>, 1}
        end
      "queen" ->
        {<<100+i>>, 1}
      "king" ->
        {<<101+i>>, 1}
    end
  end

  def pieces_id(role, i) do
    #IO.inspect {role, i}
    case role do
      "bishop" -> "b"<>Integer.to_string(i + 1)
      "king" -> "k"<>Integer.to_string(i + 1)
      "knight" -> "n"<>Integer.to_string(i + 1)
      "pone" -> "p"<>Integer.to_string(i + 1)
      "queen" -> "q"<>Integer.to_string(i + 1)
      "rook" -> "r"<>Integer.to_string(i + 1)
    end
  end

end
