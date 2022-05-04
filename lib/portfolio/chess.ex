defmodule Portfolio.Chess do
  alias Portfolio.ChessTiles
  require Integer

  def fill_board(i, j, k, chess_board) when k > 7 do
    IO.puts("end of process")
    chess_board
  end

  def fill_board(i, j, k, chess_board) when i > 7 do
    # i 0..7 =  row a1 b1 c1 d1 e1 f1 g1 h1 .. row a8 b8 c8 d8 e8 f8 g8 h8
    # IO.puts("j: #{j}\ni: #{i}")
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

  def fill_board(i \\ 0, j \\ 0, k \\ 0, chess_board \\ %{}) do
    # actual chess row and columns & color b/w
    alpha_list = ["a", "b", "c", "d", "e", "f", "g", "h"]
    no_range = 1..8
    color_tuple = {:BLACK, :WHITE}

    IO.puts("j: #{j}")
    if j > 1 do
      j = 0
      board = ChessTiles.tiles(
        alpha: elem(Enum.fetch(alpha_list, i), 1),
        color: elem(color_tuple, j),
        no: elem(Enum.fetch(no_range, k), 1))

        chess_board = Map.put(chess_board, String.to_atom(elem(Enum.fetch(alpha_list, i), 1) <> Integer.to_string(elem(Enum.fetch(no_range, k), 1))), board)

        #call itself to iterate
      fill_board(i + 1, j + 1, k, chess_board)
    else
      board = ChessTiles.tiles(
        alpha: elem(Enum.fetch(alpha_list, i), 1),
        color: elem(color_tuple, j),
        no: elem(Enum.fetch(no_range, k), 1))

        chess_board = Map.put(chess_board, String.to_atom(elem(Enum.fetch(alpha_list, i), 1) <> Integer.to_string(elem(Enum.fetch(no_range, k), 1))), board)

        #call itself to iterate
      fill_board(i + 1, j + 1, k,chess_board)
    end

  end
end
