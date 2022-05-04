defmodule Portfolio.Chess do
  alias Portfolio.ChessTiles

  def fill_board(i, j, chess_board) when i > 7 do
    # i 0..7 = first row a1 b1 c1 d1 e1 f1 g1 h1
    IO.puts("end of process")
    chess_board
  end

  def fill_board(i, j, chess_board) do
    # actual chess row and columns & color b/w
    alpha_list = ["A", "B", "C", "D", "E", "F", "G", "H"]
    no_range = 1..8
    color_tuple = {:BLACK, :WHITE}

    if j >= 2 do
      j = 0
      board = ChessTiles.tiles(
        alpha: elem(Enum.fetch(alpha_list, i), 1),
        color: elem(color_tuple, j),
        no: elem(Enum.fetch(no_range, 0), 1))
        chess_board = Map.put(chess_board, String.to_atom(elem(Enum.fetch(alpha_list, i), 1)), board)
        IO.inspect(chess_board)
      #call itself to iterate
      fill_board(i + 1, j + 1, chess_board)
    else
      board = ChessTiles.tiles(
        alpha: elem(Enum.fetch(alpha_list, i), 1),
        color: elem(color_tuple, j),
        no: elem(Enum.fetch(no_range, 0), 1))
        chess_board = Map.put(chess_board, String.to_atom(elem(Enum.fetch(alpha_list, i), 1)), board)
        IO.inspect(chess_board)
      #call itself to iterate
      fill_board(i + 1, j + 1, chess_board)
    end
  end
end
