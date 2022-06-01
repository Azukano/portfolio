defmodule Portfolio.ChessPieces do
  @enforce_keys [:role, :coordinate_alpha, :coordinate_no, :role_id]
  defstruct  [:role, :coordinate_alpha, :coordinate_no, :role_id]

  alias Portfolio.ChessPieces

  def pieces(role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, role_id: id) do
    %ChessPieces{role: role, coordinate_alpha: coordinate_alpha, coordinate_no: coordinate_no, role_id: id}
  end
end
