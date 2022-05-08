defmodule Portfolio.ChessPieces do
  @enforce_keys [:role, :coordinate_alpha, :coordinate_no]
  defstruct  [:role, :coordinate_alpha, :coordinate_no]

  alias Portfolio.ChessPieces

  def pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no) do
    %ChessPieces{role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no}
  end
end
