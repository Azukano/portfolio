defmodule Portfolio.Chess do
  alias Portfolio.ChessTiles
  alias Portfolio.ChessPieces
  require Integer

  def fill_board(i, j, k, chess_board) when k > 7 do
    chess_board
  end

  def fill_board(i, j, k, chess_board) when i > 7 do
    # i 0..7 =  row a1 b1 c1 d1 e1 f1 g1 h1 .. row a8 b8 c8 d8 e8 f8 g8 h8
    i = 0
    k = k + 1 #increase row
    # conditional guard for increasing the row e.a 1st row to 2nd row
    if Integer.is_odd(k) do
      j = 1 #white
      fill_board(i, j, k,chess_board)
    else
      j = 0 #black
      fill_board(i, j, k,chess_board)
    end
  end

  def fill_board(i, j, k, chess_board) when j > 1 do
    fill_board(i, j = 0, k, chess_board)
  end

  def fill_board(i \\ 0, j \\ 0, k \\ 0, chess_board \\ %{}) do
    # actual chess row and columns & color b/w
    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    no_range = 1..8
    color_tuple = {:BLACK, :WHITE}

      board = ChessTiles.tiles(
        alpha: elem(Enum.fetch(alpha_list, i), 1),
        color: elem(color_tuple, j),
        no: elem(Enum.fetch(no_range, k), 1))

      # !IMPORTANT Map.put 2nd arg :a1 concatinated alpha + no
      chess_board = Map.put(chess_board, String.to_atom(elem(Enum.fetch(alpha_list, i), 1) <> Integer.to_string(elem(Enum.fetch(no_range, k), 1))), board)

      #call itself to iterate
      fill_board(i + 1, j + 1, k, chess_board)
  end

  def spawn_pieces(i, j, pieces) when j > 5 do
    IO.puts "End of process"
    pieces
  end

  def spawn_pieces(i \\ 0, j \\ 0, pieces \\ %{}) do
    # roles: pones, knights, bishops, rooks, queen/s, king/s
    # position: ID of chess tiles :a1 .. :h8
    # roles_list = ["pone", "knight", "bishop", "rook", "queen", "king"
    pieces_map = %{bishop: 2, king: 1, knight: 2, pone: 8, queen: 1, rook: 2}

    #IO.puts "#{j}"

    role  = pieces_map
      |> Enum.fetch(j)                # index pointer in pieces_map
      |> elem(1)                      # index pointer in tuple returned by fetch {:ok, x} always X so 1!
      |> elem(0)                      # index pointer in tuple returned inside (i)element of map 0 = name; 1 = count of map
      |> Atom.to_string()             #return text type
    position = :x0                    #TLDR;

    if i >= (pieces_map |> Enum.fetch(j) |> elem(1) |> elem(1)) - 1 do
      #IO.inspect role
      #IO.puts "piece: #{pieces_map |> Enum.fetch(j) |> elem(1) |> elem(0)}: #{pieces_map |> Enum.fetch(0) |> elem(1) |> elem(1)}"
      #IO.puts "IF #{i} \ #{j}"
      piece = ChessPieces.pieces(role: role, position: position)
      pieces = Map.put(pieces, String.to_atom(role <> Integer.to_string(i + 1)), piece)
      j = j + 1
      spawn_pieces(0, j, pieces)
    else
      #IO.inspect role
      #IO.puts "piece: #{pieces_map |> Enum.fetch(j) |> elem(1) |> elem(0)}: #{pieces_map |> Enum.fetch(0) |> elem(1) |> elem(1)}"
      #IO.puts "ELSE #{i} \ #{j}"
      piece = ChessPieces.pieces(role: role, position: position)
      pieces = Map.put(pieces, String.to_atom(role <> Integer.to_string(i + 1)), piece)
      spawn_pieces(i + 1, j, pieces)
    end


  end

end
