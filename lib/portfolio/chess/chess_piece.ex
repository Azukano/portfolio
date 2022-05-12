defmodule Portfolio.ChessPieces do
  @enforce_keys [:role, :coordinate_alpha, :coordinate_no, :legal_move]
  defstruct  [:role, :coordinate_alpha, :coordinate_no, :legal_move]

  alias Portfolio.ChessPieces

  def pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, legal_move: legal_move) do
    %ChessPieces{role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, legal_move: legal_move}
  end
end
